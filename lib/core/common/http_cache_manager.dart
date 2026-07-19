import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mikan/core/common/log.dart';

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

  static HttpCacheManager? _instance;

  /// Returns true if the manager has been initialized.
  static bool get isInitialized => _instance != null;

  static Future<void> init({String? cacheDir}) async {
    if (_instance != null) {
      return;
    }
    final resolvedCacheDir = cacheDir?.isNotEmpty ?? false
        ? cacheDir!
        : '${(await getApplicationSupportDirectory()).path}${Platform.pathSeparator}http_cache';
    _instance = HttpCacheManager._(resolvedCacheDir);
  }

  static final HttpClient _client = HttpClient()
    ..autoUncompress = false
    ..connectionTimeout = const Duration(seconds: 30)
    ..idleTimeout = const Duration(minutes: 2);

  static final Map<String, _TaskInfo> _tasks = <String, _TaskInfo>{};

  /// Builds the deduplication key for an in-flight request. Requests are only
  /// considered identical when they share the same url, cacheKey, and headers,
  /// so a second caller with different headers/cacheKey is never silently
  /// folded into (and corrupted by) an in-flight download.
  static String _dedupKey(String url, {String? cacheKey, Map<String, dynamic>? headers}) {
    const sep = '\u0000';
    if (headers == null || headers.isEmpty) {
      return cacheKey == null ? url : '$url$sep$cacheKey';
    }
    // Stable, sorted serialization of headers.
    final sortedKeys = headers.keys.toList()..sort();
    final headerSig = sortedKeys.map((k) => '$k=${headers[k]}').join('\u{001F}');
    return '$url$sep${cacheKey ?? ''}$sep$headerSig';
  }

  static Future<File?> get(
    String url, {
    String? cacheKey,
    Map<String, dynamic>? headers,
    Cancelable? cancelable,
    StreamController<ProgressChunkEvent>? chunkEvents,
  }) async {
    final instance = _instance;
    if (instance == null) {
      throw StateError('HttpCacheManager not initialized. Call init() first.');
    }

    final dedupKey = _dedupKey(url, cacheKey: cacheKey, headers: headers);
    final _TaskInfo? existingTask = _tasks[dedupKey];
    if (existingTask != null) {
      return existingTask.completer.future;
    }

    final Completer<File?> completer = Completer<File?>();
    final taskInfo = _TaskInfo(completer: completer);
    _tasks[dedupKey] = taskInfo;

    void cleanup() {
      _tasks.remove(dedupKey);
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

    unawaited(
      instance
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
          .whenComplete(cleanup),
    );

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
      await metaFile.writeAsString(
        jsonEncode({'etag': metadata.etag, 'last_modified': metadata.lastModified, 'expires_at': metadata.expiresAt}),
      );
    } catch (e) {
      Log.w('Failed to save metadata for $key: $e', tag: 'HttpCacheManager');
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

  /// Validates that a 206 response's `Content-Range` starts exactly at
  /// [received], so appending to the existing temp file produces a correct,
  /// non-duplicated byte stream. Returns false when the header is missing or
  /// the start byte does not match, in which case the caller must restart the
  /// download from scratch instead of resuming.
  ///
  /// The header format is `bytes <start>-<end>/<total>` (RFC 7233). Some
  /// origins also return `bytes */<total>` for unsatisfiable ranges.
  static bool _contentRangeStartsAt(HttpClientResponse response, int received) {
    final raw = response.headers.value(HttpHeaders.contentRangeHeader);
    if (raw == null || raw.isEmpty) {
      return false;
    }
    // Strip the unit prefix ("bytes "). Values are case-insensitive per spec.
    final spaceIdx = raw.indexOf(' ');
    final rangePart = spaceIdx >= 0 ? raw.substring(spaceIdx + 1) : raw;
    final dashIdx = rangePart.indexOf('-');
    if (dashIdx <= 0) {
      return false;
    }
    final startStr = rangePart.substring(0, dashIdx);
    final start = int.tryParse(startStr);
    return start != null && start == received;
  }

  /// Compares the validator headers (ETag / Last-Modified) between the HEAD
  /// probe and the actual GET response to detect a resource that changed
  /// between the two requests.
  ///
  /// This guards resume downloads against silent corruption: if the upstream
  /// resource was mutated between the HEAD (which sized the file to decide
  /// whether to resume) and the GET, appending the new tail to the old
  /// partial temp file would produce a byte stream that belongs to two
  /// different versions. When this returns false, the caller must discard the
  /// temp file and restart the download from scratch.
  ///
  /// - If the HEAD response carried an `ETag`, the GET must match it.
  /// - Otherwise, if it carried a `Last-Modified`, the GET must match that.
  /// - If neither was present on HEAD there is nothing to compare, so the
  ///   response is treated as consistent (best-effort).
  static bool _isConsistentWithHead(HttpClientResponse getResponse, HttpClientResponse? headResponse) {
    if (headResponse == null) {
      return true;
    }
    final headEtag = headResponse.headers.value(HttpHeaders.etagHeader);
    if (headEtag != null) {
      return headEtag == getResponse.headers.value(HttpHeaders.etagHeader);
    }
    final headLastModified = headResponse.headers.value(HttpHeaders.lastModifiedHeader);
    if (headLastModified != null) {
      return headLastModified == getResponse.headers.value(HttpHeaders.lastModifiedHeader);
    }
    return true;
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
      Log.w('HEAD request failed for $uri: $e', tag: 'HttpCacheManager');
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
      Log.w('Conditional request failed for $uri: $e', tag: 'HttpCacheManager');
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
                final expiresAt = maxAge > 0 ? DateTime.now().millisecondsSinceEpoch + maxAge * 1000 : null;
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
    return _download(
      uri,
      cacheFile,
      tempFile,
      key,
      cacheDir,
      headers: headers,
      chunkEvents: chunkEvents,
      cancelable: cancelable,
    );
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
    final bool supportsRange =
        headResponse?.headers.value(HttpHeaders.acceptRangesHeader) == 'bytes' && (expectedSize ?? 0) > 0;

    HttpClientResponse response;
    int received = 0;
    FileMode fileMode = FileMode.write;

    // Check if we can resume from temp file
    if (supportsRange && expectedSize != null && tempFile.existsSync()) {
      final isValidResume = await _isValidTempFile(tempFile, expectedSize);
      if (isValidResume) {
        received = await tempFile.length();
        // The HEAD response has already been inspected for size/validators;
        // drain it now to release its connection regardless of the resume
        // outcome below. (In the non-resume path it is drained further down.)
        try {
          await headResponse?.drain<void>();
        } catch (_) {}
        final request = await _client.getUrl(uri);
        headers?.forEach((String k, dynamic v) => request.headers.add(k, v));
        request.headers.add(HttpHeaders.rangeHeader, 'bytes=$received-');
        response = await request.close();

        if (response.statusCode == HttpStatus.partialContent &&
            _contentRangeStartsAt(response, received) &&
            _isConsistentWithHead(response, headResponse)) {
          // Resume successful — the server honored our Range request, the
          // Content-Range start matches the bytes we already have, and the
          // resource is the same version the HEAD saw (same ETag /
          // Last-Modified), so appending is safe.
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
        try {
          await headResponse?.drain<void>();
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
      // Clean up any partial temp file so it can't accumulate as disk leak.
      if (tempFile.existsSync()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      return null;
    }

    // Download and handle gzip
    final bool compressed = response.compressionState == HttpClientResponseCompressionState.compressed;
    final int? total = compressed || response.contentLength < 0 ? null : response.contentLength;

    final completer = Completer<File>();
    final sink = tempFile.openWrite(mode: fileMode);
    // Owns the subscription + sink so that cancel, error, and done paths never
    // double-close the sink or double-cancel the subscription.
    final session = _DownloadSession();
    late StreamSubscription<List<int>> subscription;

    subscription = response.listen(
      (bytes) {
        sink.add(bytes);
        received += bytes.length;
        _emitProgress(uri, chunkEvents, received, total);
      },
      onDone: () async {
        try {
          await session.finish(sink);
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
          final expiresAt = maxAge != null && maxAge > 0 ? DateTime.now().millisecondsSinceEpoch + maxAge * 1000 : null;

          if (maxAge != 0) {
            // Cache the file
            await _saveMetadata(
              cacheDir,
              key,
              _CacheMetadata(etag: etag, lastModified: lastModified, expiresAt: expiresAt),
            );

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
        await session.dispose(subscription, sink);
        if (!completer.isCompleted) {
          completer.completeError(err, stackTrace);
        }
      },
      cancelOnError: true,
    );

    // Register the cancel handler BEFORE returning, so a cancel that races
    // with the stream is handled in exactly one place. The previous code
    // registered this after listen() returned and also re-checked isCancelled
    // inside onData, which could double-close the sink.
    cancelable?.onBeforeCancel(() async {
      await session.dispose(subscription, sink);
      if (!completer.isCompleted) {
        completer.completeError(StateError('Request canceled'));
      }
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
  _TaskInfo({required this.completer});

  final Completer<File?> completer;
}

/// Serializes teardown of an in-flight download so that the done, error, and
/// cancel paths never concurrently close the [IOSink] or cancel the
/// subscription. [dispose] is idempotent; concurrent callers await the same
/// teardown future.
class _DownloadSession {
  Future<void>? _disposeFuture;
  bool _finishing = false;

  /// Marks the sink closed on the natural-completion (done) path. Distinct
  /// from [dispose] because the done handler must not cancel the (already
  /// finished) subscription, only close the sink exactly once.
  Future<void> finish(IOSink sink) {
    if (_finishing) {
      return _disposeFuture ?? Future<void>.value();
    }
    _finishing = true;
    _disposeFuture = sink.close();
    return _disposeFuture!;
  }

  /// Cancels the subscription and closes the sink exactly once. Safe to call
  /// from the cancel callback and the error callback concurrently.
  Future<void> dispose(StreamSubscription<List<int>> subscription, IOSink sink) {
    if (_disposeFuture != null) {
      return _disposeFuture!;
    }
    _disposeFuture = () async {
      try {
        await subscription.cancel();
      } catch (_) {}
      try {
        await sink.close();
      } catch (_) {}
    }();
    return _disposeFuture!;
  }
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
      identical(this, other) ||
      other is ProgressChunkEvent &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          progress == other.progress &&
          total == other.total;

  @override
  int get hashCode => Object.hash(key, progress, total);
}

typedef FutureOrVoidCallback = FutureOr<void> Function();

@immutable
class _CacheMetadata {
  const _CacheMetadata({this.etag, this.lastModified, this.expiresAt});

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
