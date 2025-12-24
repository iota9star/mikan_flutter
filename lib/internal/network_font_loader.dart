import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'http_cache_manager.dart';

/// Maximum number of fonts to load concurrently
const int _maxConcurrentLoads = 3;

class NetworkFontLoader {
  NetworkFontLoader._();

  static late final NetworkFontLoader _fontManager;

  static final Map<String, Completer<void>> _loadingFonts = <String, Completer<void>>{};

  static Future<void> init({String? cacheDir}) async {
    _fontManager = NetworkFontLoader._();
  }

  static Future<void> load(
    String fontFamily,
    List<String> urls, {
    Map<String, dynamic>? headers,
    StreamController<Iterable<ProgressChunkEvent>>? chunkEvents,
    Cancelable? cancelable,
  }) async {
    await _fontManager._load(fontFamily, urls, headers: headers, chunkEvents: chunkEvents, cancelable: cancelable);
  }

  static void clearLoadingState(String fontFamily) {
    final Completer<void>? completer = _loadingFonts.remove(fontFamily);
    completer?.complete();
  }

  static List<String> getLoadingFonts() => _loadingFonts.keys.toList();

  Future<ByteData> _loadFont(
    String url, {
    Map<String, dynamic>? headers,
    StreamController<ProgressChunkEvent>? chunkEvents,
    Cancelable? cancelable,
  }) async {
    // Use font-specific cache key to avoid conflicts
    final String cacheKey = 'font_${base64Url.encode(utf8.encode(url))}';
    final File? file = await HttpCacheManager.get(
      url,
      cacheKey: cacheKey,
      headers: headers,
      chunkEvents: chunkEvents,
      cancelable: cancelable,
    );
    if (file == null) {
      throw StateError('Failed to load font from $url');
    }
    
    final Uint8List bytes = await file.readAsBytes();
    
    // Validate font file (basic validation - SFNT header)
    if (bytes.length < 4) {
      throw StateError('Font file is too small to be valid: $url');
    }
    
    final int header = (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
    if (header != 0x00010000 && header != 0x74727565 && // TrueType
        header != 0x4F54544F && // OpenType (CFF)
        header != 0x774F4646) { // WOFF
      throw StateError('Invalid font file header for $url');
    }
    
    return ByteData.view(bytes.buffer);
  }

  Future<void> _load(
    String fontFamily,
    List<String> urls, {
    Map<String, dynamic>? headers,
    StreamController<Iterable<ProgressChunkEvent>>? chunkEvents,
    Cancelable? cancelable,
  }) async {
    final completer = Completer<void>();
    _loadingFonts[fontFamily] = completer;

    StreamController<ProgressChunkEvent>? eventBus;
    bool eventBusClosed = false;
    final Set<String> failedUrls = <String>{};

    try {
      if (chunkEvents != null) {
        final Map<Uri, ProgressChunkEvent> combine = <Uri, ProgressChunkEvent>{};
        eventBus = StreamController<ProgressChunkEvent>(
          onCancel: () {
            eventBusClosed = true;
          },
        );
        eventBus.stream.listen(
          (ProgressChunkEvent event) {
            if (!eventBusClosed) {
              combine[event.key] = event;
              chunkEvents.sink.add(combine.values);
            }
          },
          onError: (_) {},
          cancelOnError: false,
        );
      }

      final FontLoader fontLoader = FontLoader(fontFamily);
      final List<Future<ByteData>> loadFutures = <Future<ByteData>>[];
      final Map<Future<ByteData>, String> futureToUrl = <Future<ByteData>, String>{};

      for (final String url in urls) {
        final Future<ByteData> bytes = _loadFont(
          url,
          headers: headers,
          chunkEvents: eventBus,
          cancelable: cancelable,
        );
        loadFutures.add(bytes);
        futureToUrl[bytes] = url;
      }

      // Load fonts with limited concurrency
      final List<ByteData?> results = await _loadWithConcurrency(
        loadFutures,
        maxConcurrent: _maxConcurrentLoads,
        cancelable: cancelable,
        futureToUrl: futureToUrl,
        failedUrls: failedUrls,
      );

      for (int i = 0; i < results.length; i++) {
        final ByteData? result = results[i];
        if (result != null) {
          fontLoader.addFont(Future<ByteData>.value(result));
        }
      }

      if (results.any((ByteData? data) => data != null)) {
        await fontLoader.load();
      } else {
        throw StateError('No valid fonts were loaded for $fontFamily. Failed URLs: ${failedUrls.join(', ')}');
      }

      if (!completer.isCompleted) {
        completer.complete();
      }
    } finally {
      if (eventBus != null && !eventBus.isClosed) {
        await eventBus.close();
      }
      _loadingFonts.remove(fontFamily);
      if (!completer.isCompleted) {
        completer.completeError(StateError('Font loading failed for $fontFamily'));
      }
    }
  }

  Future<List<ByteData?>> _loadWithConcurrency(
    List<Future<ByteData>> futures, {
    required int maxConcurrent,
    Cancelable? cancelable,
    required Map<Future<ByteData>, String> futureToUrl,
    required Set<String> failedUrls,
  }) async {
    final List<ByteData?> results = List<ByteData?>.filled(futures.length, null);
    int currentIndex = 0;
    final Set<Completer<void>> activeTasks = <Completer<void>>{};

    Future<void> loadNext() async {
      while (currentIndex < futures.length && activeTasks.length < maxConcurrent) {
        if (cancelable?.isCancelled ?? false) {
          return;
        }

        final int index = currentIndex++;
        final Future<ByteData> future = futures[index];
        final String url = futureToUrl[future]!;

        final Completer<void> taskCompleter = Completer<void>();
        activeTasks.add(taskCompleter);

        unawaited(
          future.then((ByteData data) {
            results[index] = data;
          }).catchError((Object error, StackTrace stackTrace) {
            results[index] = null;
            failedUrls.add(url);
            debugPrint('Failed to load font $url: $error');
          }).whenComplete(() {
            if (!taskCompleter.isCompleted) {
              taskCompleter.complete();
              activeTasks.remove(taskCompleter);
            }
          }),
        );
      }
    }

    await loadNext();

    while (activeTasks.isNotEmpty) {
      if (cancelable?.isCancelled ?? false) {
        break;
      }
      await Future.any(activeTasks.map((c) => c.future));
      await loadNext();
    }

    return results;
  }
}
