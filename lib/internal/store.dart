import 'dart:io';

import 'package:mikan_flutter/internal/hive.dart';
import 'package:path_provider/path_provider.dart';

class Store {
  Store._();

  static Directory cacheDir;
  static Directory docDir;
  static Directory filesDir;

  static init() async {
    cacheDir = await getTemporaryDirectory();
    docDir = await getApplicationDocumentsDirectory();
    filesDir = await getApplicationSupportDirectory();
  }

  static setLogin(final Map<String, dynamic> login) {
    MyHive.db.put(HiveBoxKey.LOGIN, login);
  }

  static Map<String, dynamic> getLogin() {
    return MyHive.db.get(HiveBoxKey.LOGIN,
        defaultValue: <String, dynamic>{}).cast<String, dynamic>();
  }
}
