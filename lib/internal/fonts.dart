import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:mikan_flutter/internal/http_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class FontManager {
  final String _cacheDir;

  FontManager._(this._cacheDir);

  static late final FontManager _fontManager;

  static Future<void> init({String? cacheDir}) async {
    if (cacheDir == null || cacheDir.isEmpty) {
      cacheDir = (await getApplicationSupportDirectory()).path +
          Platform.pathSeparator +
          "font_manager_cache";
    }
    final Directory directory = Directory(cacheDir);
    if (!directory.existsSync()) {
      directory.create(recursive: true);
    }
    _fontManager = FontManager._(cacheDir);
  }

  static Future<void> load(
    String fontFamily,
    List<String> urls, {
    Map<String, dynamic>? headers,
  }) async {
    await _fontManager._load(fontFamily, urls, headers: headers);
  }

  Future<ByteData> _loadFont(
    String url, {
    Map<String, dynamic>? headers,
    String? cacheDir,
  }) async {
    final File? file = await HttpCacheManager.get(
      url,
      headers: headers,
      cacheDir: cacheDir,
    );
    if (file == null) {
      return Future.error("Get font<$url> error");
    }
    final Uint8List bytes = await file.readAsBytes();
    return ByteData.view(bytes.buffer);
  }

  Future<void> _load(
    String fontFamily,
    List<String> urls, {
    Map<String, dynamic>? headers,
  }) async {
    final FontLoader fontLoader = FontLoader(fontFamily);
    urls.forEach((url) {
      fontLoader.addFont(_loadFont(
        url,
        headers: headers,
        cacheDir: _fontManager._cacheDir,
      ));
    });
    await fontLoader.load();
  }
}
