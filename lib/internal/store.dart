import 'dart:io';

import 'package:mikan_flutter/internal/hive.dart';
import 'package:path_provider/path_provider.dart';

class Store {
  Store._();

  static late Directory cacheDir;
  static late Directory docDir;
  static late Directory filesDir;

  static late String cookiesPath;

  static const int KB = 1024;
  static const int MB = 1024 * KB;
  static const int GB = 1024 * MB;

  static Future<void> init() async {
    cacheDir = await getTemporaryDirectory();
    docDir = await getApplicationDocumentsDirectory();
    filesDir = await getApplicationSupportDirectory();
    cookiesPath = "${cacheDir.path}/cookies";
  }

  static setLogin(final Map<String, dynamic> login) {
    MyHive.db.put(HiveBoxKey.login, login);
  }

  static removeLogin() {
    MyHive.db.delete(HiveBoxKey.login);
  }

  static Map<String, dynamic> getLogin() {
    return MyHive.db.get(HiveBoxKey.login,
        defaultValue: <String, dynamic>{}).cast<String, dynamic>();
  }

  static removeCookies() async {
    final Directory dir = Directory(cookiesPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  static Future<void> clearCache() async {
    await Future.wait(
      <Future<void>>[
        for (final FileSystemEntity f in cacheDir.listSync())
          f.delete(recursive: true),
      ],
    );
  }

  static Future<int> getCacheSize() async {
    final List<FileSystemEntity> listSync = cacheDir.listSync(recursive: true);
    int size = 0;
    for (final FileSystemEntity file in listSync) {
      size += file.statSync().size;
    }
    return size;
  }

  static Future<String> getFormatCacheSize() async {
    final int size = await getCacheSize();
    if (size >= GB) {
      return '${(size / GB).toStringAsFixed(2)} GB';
    }
    if (size >= MB) {
      return '${(size / MB).toStringAsFixed(2)} MB';
    }
    if (size >= KB) {
      return '${(size / KB).toStringAsFixed(2)} KB';
    }
    return '$size B';
  }
}
