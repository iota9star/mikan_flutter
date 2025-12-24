import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// HTTP cache manager implementing RFC 7234 caching semantics.
///
/// Supports:
/// - Cache-Control (no-store, max-age, s-maxage)
/// - ETag validation (If-None-Match)
/// - Last-Modified validation (If-Modified-Since)
/// - 304 Not Modified handling
/// - Range requests for resume (breakpoint transmission)
/// - Progress callbacks
/// - Request cancellation
/// - Concurrent request deduplication
class HttpCacheManager {
  HttpCacheManager._(this._cacheDir);

  final String _cacheDir;

  static HttpCacheManager? _httpCacheManager;

  static Future<void> init({String? cacheDir}) async {
    if (_httpCacheManager != null) {
      return;
    }
    if (cacheDir == null || cacheDir.isEmpty) {
      cacheDir = '${(await getApplicationSupportDirectory()).path}${Platform.pathSeparator}http_cache';
    }
    _httpCacheManager = HttpCacheManager._(cacheDir);
  }

  static final HttpClient _client = HttpClient()
    ..autoUncompress = false
    ..connectionTimeout = const Duration(seconds: 30)
    ..idleTimeout = const Duration(minutes: 2);

  static final Map<String, _TaskInfo> _tasks = <String, _TaskInfo>{};

  static Future<File?> get(
    String url, {
    String? cacheKey,
    Map<String, dynamic>? headers,
    Cancelable? cancelable,
    StreamController<ProgressChunkEvent>? chunkEvents,
  }) async {
    final _TaskInfo? existingTask = _tasks[url];
    if (existingTask != null) {
      if (cancelable != null) {
        existingTask.cancelable = cancelable;
      }
      return existingTask.completer.future;
    }

    final Completer<File?> completer = Completer<File?>();
    final taskInfo = _TaskInfo(completer: completer, cancelable: cancelable);
    _tasks[url] = taskInfo;

    void cleanup() {
      _tasks.remove(url);
    }

    // Register cancel handler
    void onCancel() {
      if (!completer.isCompleted) {
        cleanup();
        completer.completeError(StateError('Request canceled'));
      }
    }

    if (cancelable != null) {
      cancelable.onBeforeCancel(onCancel);
    }

    final instance = _httpCacheManager;
    if (instance == null) {
      throw StateError('HttpCacheManager not initialized. Call init() first.');
    }
    unawaited(instance
        ._get(url, cacheKey: cacheKey, headers: headers, chunkEvents: chunkEvents, cancelable: cancelable)
        .then((result) {
          if (!completer.isCompleted) {
            completer.complete(result);
          }
        })
        .catchError((Object error, StackTrace stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }
        })
        .whenComplete(cleanup));

    return completer.future;
  }

  Future<Directory> _getCacheDir() async {
    final Directory dir = Directory(_cacheDir);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  File _cacheFile(Directory cacheDir, String key) {
    return File('${cacheDir.path}${Platform.pathSeparator}$key');
  }

  File _tempFile(Directory cacheDir, String key) {
    return File('${cacheDir.path}${Platform.pathSeparator}$key.tmp');
  }

  File _metadataFile(Directory cacheDir, String key) {
    return File('${cacheDir.path}${Platform.pathSeparator}$key.meta');
  }

  /// Parse max-age from Cache-Control header
  static int? _parseMaxAge(String cacheControl) {
    // Check for no-store first
    if (cacheControl.contains('no-store')) {
      return 0;
    }

    // Try s-maxage first (CDN cache), then max-age
    for (final String key in ['s-maxage', 'max-age']) {
      if (cacheControl.contains(key)) {
        final int idx = cacheControl.indexOf(key);
        final int equalIdx = cacheControl.indexOf('=', idx);
        if (equalIdx > idx) {
          final String value = cacheControl.substring(equalIdx + 1).split(RegExp(r'[,\s]')).first;
          return int.tryParse(value);
        }
      }
    }
    return null;
  }

  /// Load cached metadata
  Future<_CacheMetadata?> _loadMetadata(Directory cacheDir, String key) async {
    try {
      final metaFile = _metadataFile(cacheDir, key);
      if (!metaFile.existsSync()) {
        return null;
      }
      final String content = await metaFile.readAsString();
      final Map<String, dynamic> json = jsonDecode(content);
      return _CacheMetadata(
        etag: json['etag'] as String?,
        lastModified: json['last_modified'] as String?,
        expiresAt: json['expires_at'] as int?,
      );
    } catch (_) {
      return null;
    }
  }

  /// Save cached metadata
  Future<void> _saveMetadata(Directory cacheDir, String key, _CacheMetadata metadata) async {
    try {
      final metaFile = _metadataFile(cacheDir, key);
      await metaFile.writeAsString(jsonEncode({
        'etag': metadata.etag,
        'last_modified': metadata.lastModified,
        'expires_at': metadata.expiresAt,
      }));
    } catch (e) {
      debugPrint('Failed to save metadata for $key: $e');
    }
  }

  /// Check if cache is expired
  bool _isExpired(_CacheMetadata metadata) {
    return metadata.expiresAt != null && metadata.expiresAt! < DateTime.now().millisecondsSinceEpoch;
  }

  /// Check if temp file is valid for resume
  Future<bool> _isValidTempFile(File tempFile, int expectedSize) async {
    try {
      final currentSize = await tempFile.length();
      return currentSize > 0 && currentSize < expectedSize;
    } catch (_) {
      return false;
    }
  }

  /// Perform HEAD request to check cache status
  Future<HttpClientResponse?> _headRequest(Uri uri, {Map<String, dynamic>? headers}) async {
    try {
      final request = await _client.headUrl(uri);
      headers?.forEach((String key, dynamic value) {
        request.headers.add(key, value);
      });
      final response = await request.close();
      if (response.statusCode >= 500) {
        await response.drain<void>();
        return null;
      }
      return response;
    } catch (e) {
      debugPrint('HEAD request failed for $uri: $e');
      return null;
    }
  }

  /// Perform conditional request using cached metadata
  Future<HttpClientResponse?> _conditionalRequest(
    Uri uri,
    _CacheMetadata metadata, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      final HttpClientRequest request = await _client.getUrl(uri);

      // Add custom headers
      headers?.forEach((String key, dynamic value) {
        request.headers.add(key, value);
      });

      // Add conditional headers
      if (metadata.etag != null) {
        request.headers.add(HttpHeaders.ifNoneMatchHeader, metadata.etag!);
      }
      if (metadata.lastModified != null) {
        request.headers.add(HttpHeaders.ifModifiedSinceHeader, metadata.lastModified!);
      }

      final response = await request.close();
      if (response.statusCode >= 500) {
        await response.drain<void>();
        return null;
      }
      return response;
    } catch (e) {
      debugPrint('Conditional request failed for $uri: $e');
      return null;
    }
  }

  /// Emit progress event
  void _emitProgress(Uri uri, StreamController<ProgressChunkEvent>? chunkEvents, int progress, int? total) {
    if (chunkEvents != null && !chunkEvents.isClosed) {
      chunkEvents.add(ProgressChunkEvent(key: uri, progress: progress, total: total));
    }
  }

  Future<File?> _get(
    String url, {
    String? cacheKey,
    Map<String, dynamic>? headers,
    StreamController<ProgressChunkEvent>? chunkEvents,
    Cancelable? cancelable,
  }) async {
    final Uri uri = Uri.parse(url);
    final key = cacheKey ?? base64Url.encode(utf8.encode(url));
    final cacheDir = await _getCacheDir();
    final cacheFile = _cacheFile(cacheDir, key);
    final tempFile = _tempFile(cacheDir, key);

    // Check if cached file exists
    if (cacheFile.existsSync()) {
      final metadata = await _loadMetadata(cacheDir, key);

      if (metadata != null && !_isExpired(metadata)) {
        // Cache is valid
        final length = await cacheFile.length();
        _emitProgress(uri, chunkEvents, length, length);
        return cacheFile;
      }

      // Check with server if cache is still valid
      if (metadata != null) {
        final response = await _conditionalRequest(uri, metadata, headers: headers);
        if (response != null) {
          try {
            if (response.statusCode == HttpStatus.notModified) {
              // 304 Not Modified - cache is still valid
              // Update expiration if server provided new Cache-Control
              final cacheControl = response.headers.value(HttpHeaders.cacheControlHeader) ?? '';
              final maxAge = _parseMaxAge(cacheControl);
              if (maxAge != null) {
                final expiresAt = maxAge > 0
                    ? DateTime.now().millisecondsSinceEpoch + maxAge * 1000
                    : null;
                await _saveMetadata(cacheDir, key, metadata.copyWith(expiresAt: expiresAt));
              }
              final length = await cacheFile.length();
              _emitProgress(uri, chunkEvents, length, length);
              return cacheFile;
            }
          } finally {
            try {
              await response.drain<void>();
            } catch (_) {}
          }
        }
      }
    }

    // No cache or cache invalid, download
    return _download(uri, cacheFile, tempFile, key, cacheDir, headers: headers, chunkEvents: chunkEvents, cancelable: cancelable);
  }

  Future<File?> _download(
    Uri uri,
    File cacheFile,
    File tempFile,
    String key,
    Directory cacheDir, {
    Map<String, dynamic>? headers,
    StreamController<ProgressChunkEvent>? chunkEvents,
    Cancelable? cancelable,
  }) async {
    // Try HEAD first to get content info
    final headResponse = await _headRequest(uri, headers: headers);
    final int? expectedSize = headResponse?.contentLength;
    final bool supportsRange = headResponse?.headers.value(HttpHeaders.acceptRangesHeader) == 'bytes' &&
        (expectedSize ?? 0) > 0;

    HttpClientResponse response;
    int received = 0;
    FileMode fileMode = FileMode.write;

    // Check if we can resume from temp file
    if (supportsRange && expectedSize != null && tempFile.existsSync()) {
      final isValidResume = await _isValidTempFile(tempFile, expectedSize);
      if (isValidResume) {
        received = await tempFile.length();
        final request = await _client.getUrl(uri);
        headers?.forEach((String k, dynamic v) => request.headers.add(k, v));
        request.headers.add(HttpHeaders.rangeHeader, 'bytes=$received-');
        response = await request.close();

        if (response.statusCode == HttpStatus.partialContent) {
          // Resume successful
          fileMode = FileMode.append;
        } else {
          // Server doesn't support resume for this request, start fresh
          try {
            await response.drain<void>();
          } catch (_) {}
          try {
            await tempFile.delete();
          } catch (_) {}
          received = 0;
          response = await _createRequest(uri, headers);
        }
      } else {
        // Temp file invalid, start fresh
        try {
          await tempFile.delete();
        } catch (_) {}
        response = await _createRequest(uri, headers);
      }
    } else {
      try {
        await headResponse?.drain<void>();
      } catch (_) {}
      response = await _createRequest(uri, headers);
    }

    if (response.statusCode != HttpStatus.ok && response.statusCode != HttpStatus.partialContent) {
      try {
        await response.drain<void>();
      } catch (_) {}
      return null;
    }

    // Download and handle gzip
    final bool compressed = response.compressionState == HttpClientResponseCompressionState.compressed;
    final int? total = compressed || response.contentLength < 0 ? null : response.contentLength;

    final completer = Completer<File>();
    final sink = tempFile.openWrite(mode: fileMode);
    late StreamSubscription<List<int>> subscription;

    subscription = response.listen(
      (bytes) {
        if (cancelable?.isCancelled ?? false) {
          subscription.cancel();
          sink.close();
          return;
        }
        sink.add(bytes);
        received += bytes.length;
        _emitProgress(uri, chunkEvents, received, total);
      },
      onDone: () async {
        try {
          await sink.close();
          File finalFile = tempFile;

          if (compressed) {
            // Decompress to new file
            final buffer = await tempFile.readAsBytes();
            final decompressed = gzip.decoder.convert(buffer);
            final decompressedBuffer = Uint8List.fromList(decompressed);
            final decompressedFile = File('${tempFile.path}.dec');
            await decompressedFile.writeAsBytes(decompressedBuffer);
            try {
              await tempFile.delete();
            } catch (_) {}
            finalFile = decompressedFile;
            _emitProgress(uri, chunkEvents, decompressedBuffer.length, decompressedBuffer.length);
          }

          // Save metadata
          final etag = response.headers.value(HttpHeaders.etagHeader);
          final lastModified = response.headers.value(HttpHeaders.lastModifiedHeader);
          final cacheControl = response.headers.value(HttpHeaders.cacheControlHeader) ?? '';
          final maxAge = _parseMaxAge(cacheControl);
          final expiresAt = maxAge != null && maxAge > 0
              ? DateTime.now().millisecondsSinceEpoch + maxAge * 1000
              : null;

          if (maxAge != 0) {
            // Cache the file
            await _saveMetadata(cacheDir, key, _CacheMetadata(
              etag: etag,
              lastModified: lastModified,
              expiresAt: expiresAt,
            ));

            if (cacheFile.existsSync()) {
              await cacheFile.delete();
            }
            await finalFile.rename(cacheFile.path);
            completer.complete(cacheFile);
          } else {
            // no-store, return temp file without caching
            completer.complete(finalFile);
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      },
      onError: (err, stackTrace) async {
        try {
          await sink.close();
        } catch (_) {}
        if (!completer.isCompleted) {
          completer.completeError(err, stackTrace);
        }
      },
      cancelOnError: true,
    );

    cancelable?.onBeforeCancel(() async {
      await subscription.cancel();
      await sink.close();
    });

    return completer.future;
  }

  Future<HttpClientResponse> _createRequest(Uri uri, Map<String, dynamic>? headers) async {
    final request = await _client.getUrl(uri);
    headers?.forEach((String key, dynamic value) {
      request.headers.add(key, value);
    });
    return request.close();
  }
}

class _TaskInfo {
  _TaskInfo({required this.completer, this.cancelable});

  final Completer<File?> completer;
  Cancelable? cancelable;
}

/// Cancelable request token
class Cancelable {
  Cancelable();

  final Set<FutureOrVoidCallback> _onBeforeCancels = {};

  void onBeforeCancel(FutureOrVoidCallback callback) {
    _onBeforeCancels.add(callback);
  }

  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  Future<void> cancel([Object? reason]) async {
    if (_isCancelled) {
      return;
    }
    for (final f in _onBeforeCancels) {
      await f();
    }
    _isCancelled = true;
  }
}

/// Progress event for download monitoring
@immutable
class ProgressChunkEvent {
  const ProgressChunkEvent({required this.key, required this.progress, required this.total});

  final dynamic key;
  final int progress;
  final int? total;

  double? get percent => total == null || total == 0 ? null : (progress / total!).clamp(0, 1);

  @override
  String toString() {
    return '{"uri": "$key","progress":$progress,"total":$total}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProgressChunkEvent && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
}

typedef FutureOrVoidCallback = FutureOr<void> Function();

@immutable
class _CacheMetadata {
  const _CacheMetadata({
    this.etag,
    this.lastModified,
    this.expiresAt,
  });

  final String? etag;
  final String? lastModified;
  final int? expiresAt;

  _CacheMetadata copyWith({String? etag, String? lastModified, int? expiresAt}) {
    return _CacheMetadata(
      etag: etag ?? this.etag,
      lastModified: lastModified ?? this.lastModified,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
