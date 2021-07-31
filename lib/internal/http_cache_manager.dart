import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class HttpCacheManager {
  final String _cacheDir;

  HttpCacheManager._(this._cacheDir);

  static late final HttpCacheManager _httpCacheManager;

  static Future<void> init({String? cacheDir}) async {
    if (cacheDir == null || cacheDir.isEmpty) {
      cacheDir = (await getApplicationSupportDirectory()).path +
          Platform.pathSeparator +
          "http_cache_manager";
    }
    _httpCacheManager = HttpCacheManager._(cacheDir);
  }

  static late final HttpClient _client = HttpClient()..autoUncompress = false;

  static late final Map<String, String> _lockCache = <String, String>{};

  static late final Map<String, CancelableCompleter<File?>> _tasks =
      <String, CancelableCompleter<File?>>{};

  static Future<void> cancel(String url) async {
    await _tasks[url]?.operation.cancel();
  }

  static Future<void> cancelAll() async {
    if (_tasks.isNotEmpty) {
      await Future.wait(_tasks.values.map((e) => e.operation.cancel()));
    }
  }

  static Future<File?> get(
    String url, {
    String? cacheDir,
    String? cacheKey,
    Map<String, dynamic>? headers,
    StreamController<ProgressChunkEvent>? chunkEvents,
  }) async {
    if (_tasks.containsKey(url)) {
      return _tasks[url]!.operation.value;
    }
    CancelableCompleter<File?> completer = CancelableCompleter();
    _httpCacheManager
        ._(
      url,
      cacheKey: cacheKey,
      cacheDir: cacheDir,
      headers: headers,
      chunkEvents: chunkEvents,
    )
        .then((value) {
      completer.complete(value);
    }).catchError((dynamic error, StackTrace stackTrace) {
      completer.completeError(error, stackTrace);
    }).whenComplete(() => _tasks.remove(url));
    _tasks[url] = completer;
    return completer.operation.value;
  }

  Future<Directory> _getCacheDir([String? cacheDir]) async {
    if (cacheDir == null) {
      if (Platform.isWindows) {
        cacheDir = (await getTemporaryDirectory()).path +
            Platform.pathSeparator +
            (await getApplicationSupportDirectory())
                .parent
                .path
                .split(Platform.pathSeparator)
                .last +
            Platform.pathSeparator +
            _cacheDir;
      } else {
        cacheDir = (await getTemporaryDirectory()).path +
            Platform.pathSeparator +
            (_cacheDir);
      }
    }
    final Directory dir = Directory(cacheDir);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  File _childFile(Directory parentDir, String fileName) {
    return File(parentDir.path + Platform.pathSeparator + fileName);
  }

  Future<File?> _(
    String url, {
    String? cacheKey,
    String? cacheDir,
    Map<String, dynamic>? headers,
    StreamController<ProgressChunkEvent>? chunkEvents,
  }) async {
    try {
      print(url);
      final Uri uri = Uri.parse(url);

      final HttpClientResponse? checkResp =
          await _createNewRequest(uri, withBody: false, headers: headers);

      final String rawFileKey =
          cacheKey ?? md5.convert(utf8.encode(url)).toString();
      final Directory parentDir = await _getCacheDir(cacheDir);
      final File rawFile = _childFile(parentDir, rawFileKey);

      // if request error, use cache.
      if (checkResp == null || checkResp.statusCode != HttpStatus.ok) {
        checkResp?.listen(null);
        if (rawFile.existsSync()) {
          await _justFinished(rawFile, chunkEvents);
          return rawFile;
        }
        return null;
      }

      // consuming response.
      checkResp.listen(null);

      bool isExpired = false;
      final String? cacheControl =
          checkResp.headers.value(HttpHeaders.cacheControlHeader);
      final File tempFile = _childFile(parentDir, '$rawFileKey.temp');
      if (cacheControl != null) {
        if (cacheControl.contains('no-store')) {
          // no cache, download now.
          return await _nrw(uri, rawFile, tempFile, chunkEvents: chunkEvents);
        } else {
          String maxAgeKey = 'max-age';
          if (cacheControl.contains(maxAgeKey)) {
            // if exist s-maxage, override max-age, use cdn max-age
            if (cacheControl.contains('s-maxage')) {
              maxAgeKey = 's-maxage';
            }
            final String maxAgeStr = cacheControl
                .split(' ')
                .firstWhere((String str) => str.contains(maxAgeKey))
                .split('=')[1]
                .trim();
            final String seconds = RegExp(r'\d+').stringMatch(maxAgeStr)!;
            final int maxAge = int.parse(seconds) * 1000;
            final String newFlag =
                '${checkResp.headers.value(HttpHeaders.etagHeader).toString()}_${checkResp.headers.value(HttpHeaders.lastModifiedHeader).toString()}';
            final File lockFile = _childFile(parentDir, '$rawFileKey.lock');
            String? lockStr = _lockCache[url];
            if (lockStr == null) {
              // never empty or blank.
              if (lockFile.existsSync()) {
                lockStr = await lockFile.readAsString();
              } else {
                await lockFile.create();
              }
            }
            final int millis = DateTime.now().millisecondsSinceEpoch;
            if (lockStr != null) {
              //never empty or blank
              final List<String> split = lockStr.split('@');
              final String flag = split[1];
              final int lastReqAt = int.parse(split[0]);
              if (flag != newFlag || lastReqAt + maxAge < millis) {
                isExpired = true;
              }
            }
            final String newLockStr = <dynamic>[millis, newFlag].join('@');
            _lockCache[url] = newLockStr;
            // we don't care lock str already written in file.
            lockFile.writeAsString(newLockStr);
          }
        }
      }
      if (!isExpired) {
        // if not expired and exist file, just return.
        if (rawFile.existsSync()) {
          await _justFinished(rawFile, chunkEvents);
          return rawFile;
        }
      }

      final bool breakpointTransmission =
          checkResp.headers.value(HttpHeaders.acceptRangesHeader) == 'bytes' &&
              checkResp.contentLength > 0;
      // if not expired && is support breakpoint transmission && temp file exists
      if (!isExpired && breakpointTransmission && tempFile.existsSync()) {
        print("xxxx: $url");
        final int length = await tempFile.length();
        print("length: $url");
        final HttpClientResponse? resp = await _createNewRequest(
          uri,
          beforeRequest: (HttpClientRequest req) {
            req.headers.add(HttpHeaders.rangeHeader, 'bytes=$length-');
            final String? flag =
                checkResp.headers.value(HttpHeaders.etagHeader) ??
                    checkResp.headers.value(HttpHeaders.lastModifiedHeader);
            if (flag != null) {
              req.headers.add(HttpHeaders.ifRangeHeader, flag);
            }
          },
          headers: headers,
        );
        if (resp == null) {
          return null;
        }
        if (resp.statusCode == HttpStatus.partialContent) {
          // is ok, continue download.
          return await _rw(
            resp,
            rawFile,
            tempFile,
            chunkEvents: chunkEvents,
            loadedLength: length,
            fileMode: FileMode.append,
          );
        } else if (resp.statusCode == HttpStatus.requestedRangeNotSatisfiable) {
          // 416 Requested Range Not Satisfiable
          return await _nrw(
            uri,
            rawFile,
            tempFile,
            chunkEvents: chunkEvents,
          );
        } else if (resp.statusCode == HttpStatus.ok) {
          return await _rw(resp, rawFile, tempFile, chunkEvents: chunkEvents);
        } else {
          // request error.
          resp.listen(null);
          return null;
        }
      } else {
        return await _nrw(
          uri,
          rawFile,
          tempFile,
          chunkEvents: chunkEvents,
        );
      }
    } finally {
      chunkEvents?.close();
    }
  }

  Future<void> _justFinished(
    File rawFile,
    StreamController<ProgressChunkEvent>? chunkEvents,
  ) async {
    if (chunkEvents != null) {
      final int length = await rawFile.length();
      chunkEvents.add(ProgressChunkEvent(
        progress: length,
        total: length,
      ));
    }
  }

  Future<File?> _nrw(
    Uri uri,
    File rawFile,
    File tempFile, {
    Map<String, dynamic>? headers,
    StreamController<ProgressChunkEvent>? chunkEvents,
  }) async {
    final HttpClientResponse? resp = await _createNewRequest(
      uri,
      headers: headers,
    );
    if (resp == null || resp.statusCode != HttpStatus.ok) {
      resp?.listen(null);
      return null;
    }
    return await _rw(
      resp,
      rawFile,
      tempFile,
      chunkEvents: chunkEvents,
    );
  }

  Future<File> _rw(
    HttpClientResponse response,
    File rawFile,
    File tempFile, {
    StreamController<ProgressChunkEvent>? chunkEvents,
    int loadedLength = 0,
    FileMode fileMode = FileMode.write,
  }) async {
    final Completer<File> completer = Completer<File>();
    int received = loadedLength;
    final bool compressed = response.compressionState ==
        HttpClientResponseCompressionState.compressed;
    final int? total = compressed || response.contentLength < 0
        ? null
        : response.contentLength;
    final IOSink ioSink = tempFile.openWrite(mode: fileMode);
    response.listen(
      (List<int> bytes) {
        ioSink.add(bytes);
        received += bytes.length;
        chunkEvents?.add(ProgressChunkEvent(
          progress: received,
          total: total,
        ));
      },
      onDone: () async {
        try {
          await ioSink.close();
          Uint8List buffer = await tempFile.readAsBytes();
          if (compressed) {
            final List<int> convert = gzip.decoder.convert(buffer);
            buffer = Uint8List.fromList(convert);
            await tempFile.writeAsBytes(convert);
            chunkEvents?.add(ProgressChunkEvent(
              progress: buffer.length,
              total: buffer.length,
            ));
          }
          await tempFile.rename(rawFile.path);
          completer.complete(rawFile);
        } catch (e) {
          completer.completeError(e);
        }
      },
      onError: (dynamic err, StackTrace stackTrace) async {
        try {
          await ioSink.close();
        } finally {
          completer.completeError(err, stackTrace);
        }
      },
      cancelOnError: true,
    );
    return completer.future;
  }

  Future<HttpClientResponse> _createNewRequest(
    Uri uri, {
    Map<String, dynamic>? headers,
    bool withBody = true,
    _BeforeRequest? beforeRequest,
  }) async {
    final HttpClientRequest request =
        await (withBody ? _client.getUrl(uri) : _client.headUrl(uri));
    headers?.forEach((String key, dynamic value) {
      request.headers.add(key, value);
    });
    beforeRequest?.call(request);
    return await request.close();
  }
}

@immutable
class ProgressChunkEvent {
  final int progress;
  final int? total;

  ProgressChunkEvent({required this.progress, required this.total});

  double? get percent => total == null || total == 0 ? null : progress / total!;
}

typedef _BeforeRequest = void Function(HttpClientRequest request);
