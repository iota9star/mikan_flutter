import 'dart:io';

import 'package:mikan_flutter/internal/hive.dart';
import 'package:path_provider/path_provider.dart';

class Store {
  Store._();

  static late Directory cacheDir;
  static late Directory docDir;
  static late Directory filesDir;

  static late String cookiesPath;

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
}
