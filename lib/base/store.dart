import 'dart:io';

import 'package:flutter/material.dart' hide Theme;
import 'package:hive/hive.dart';
import 'package:mikan_flutter/model/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  Store._();

  static SharedPreferences sp;
  static Directory cacheDir;
  static Directory docDir;
  static Directory filesDir;
  static Box<Theme> themeBox;
  static Box themeConfig;

  static getDownloadDir(String childPath) async {}

  static init() async {
    cacheDir = await getTemporaryDirectory();
    docDir = await getApplicationDocumentsDirectory();
    filesDir = await getApplicationSupportDirectory();
    sp = await SharedPreferences.getInstance();
    Hive.registerAdapter(ThemeAdapter());
    Hive.init(filesDir.path + "/hivedb");
    themeBox = await Hive.openBox<Theme>("themes");
    if (themeBox.isEmpty) {
      themeBox.addAll([
        Theme(
          id: 1,
          canDelete: false,
          autoMode: true,
          primaryColor: Colors.orange.value,
          accentColor: Colors.orange.value,
          lightBackgroundColor: Colors.white.value,
          darkBackgroundColor: Colors.black.value,
          lightScaffoldBackgroundColor: Colors.white.value,
          darkScaffoldBackgroundColor: Colors.black.value,
        ),
      ]);
    }
    themeConfig = await Hive.openBox("theme_config");
  }
}
