import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  Store._();

  static SharedPreferences sp;
  static Directory cacheDir;
  static Directory docDir;
  static Directory filesDir;

  static getDownloadDir(String childPath) async {}

  static init() async {
    cacheDir = await getTemporaryDirectory();
    docDir = await getApplicationDocumentsDirectory();
    filesDir = await getApplicationSupportDirectory();
    sp = await SharedPreferences.getInstance();
    Hive.init(filesDir.path + "/hivedb");
  }
}
