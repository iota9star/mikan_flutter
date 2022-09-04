import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// The dart:io implementation of [painting.NetworkImage].
@immutable
class CacheImageProvider extends painting.ImageProvider<painting.NetworkImage>
    implements painting.NetworkImage {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const CacheImageProvider(this.url, {this.scale = 1.0, this.headers});

  @override
  final String url;

  @override
  final double scale;

  @override
  final Map<String, String>? headers;

  @override
  Future<CacheImageProvider> obtainKey(
      painting.ImageConfiguration configuration) {
    return SynchronousFuture<CacheImageProvider>(this);
  }

  InformationCollector? _imageStreamInformationCollector(
    painting.NetworkImage key,
  ) {
    InformationCollector? collector;
    assert(() {
      collector = () => <DiagnosticsNode>[
            DiagnosticsProperty<painting.ImageProvider>('Image provider', this),
            DiagnosticsProperty<NetworkImage>('Image key', key),
          ];
      return true;
    }());
    return collector;
  }

  @override
  ImageStreamCompleter loadBuffer(
    painting.NetworkImage key,
    painting.DecoderBufferCallback decode,
  ) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      chunkEvents: chunkEvents.stream,
      codec: _loadAsync(key, chunkEvents, decode),
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: _imageStreamInformationCollector(key),
    );
  }

  // Do not access this field directly; use [_httpClient] instead.
  // We set `autoUncompress` to false to ensure that we can trust the value of
  // the `Content-Length` HTTP header. We automatically uncompress the content
  // in our call to [consolidateHttpClientResponseBytes].
  static final HttpClient _sharedHttpClient = HttpClient()
    ..autoUncompress = false;

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null) {
        client = debugNetworkImageHttpClientProvider!();
      }
      return true;
    }());
    return client;
  }

  Future<Directory> _getCacheDir() async {
    final String cacheDir;
    if (Platform.isWindows) {
      cacheDir = join(
          (await getTemporaryDirectory()).path,
          (await getApplicationSupportDirectory())
              .parent
              .path
              .split(Platform.pathSeparator)
              .last,
          "cache-image");
    } else {
      cacheDir = join((await getTemporaryDirectory()).path, "cache-image");
    }
    final Directory dir = Directory(cacheDir);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  File _childFile(Directory parentDir, String fileName) {
    return File(join(parentDir.path, fileName));
  }

  Future<ui.Codec> _loadAsync(
    painting.NetworkImage key,
    StreamController<ImageChunkEvent> chunkEvents,
    painting.DecoderBufferCallback decode,
  ) async {
    try {
      assert(key == this);
      final cacheKey = base64Url.encode(utf8.encode(key.url));
      final Directory parentDir = await _getCacheDir();
      final File cacheFile = _childFile(parentDir, cacheKey);
      if (cacheFile.existsSync()) {
        final buffer = await cacheFile.readAsBytes();
        final immutableBuffer = await ui.ImmutableBuffer.fromUint8List(buffer);
        return decode(immutableBuffer);
      }
      final Uri resolved = Uri.base.resolve(key.url);

      final HttpClientRequest request = await _httpClient.getUrl(resolved);

      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        // The network may be only temporarily unavailable, or the file will be
        // added on the server later. Avoid having future calls to resolve
        // fail to check the network again.
        await response.drain<List<int>>();
        throw painting.NetworkImageLoadException(
            statusCode: response.statusCode, uri: resolved);
      }

      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int? total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );
      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty file: $resolved');
      }

      await cacheFile.writeAsBytes(bytes);
      final ui.ImmutableBuffer buffer =
          await ui.ImmutableBuffer.fromUint8List(bytes);
      return decode(buffer);
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is CacheImageProvider && url == other.url && scale == other.scale;

  @override
  int get hashCode => url.hashCode ^ scale.hashCode;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'NetworkImage')}("$url", scale: $scale)';
}
