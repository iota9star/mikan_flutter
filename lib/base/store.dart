import 'dart:io';

import 'package:flutter/material.dart' hide Theme;
import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/model/theme.dart';
import 'package:path_provider/path_provider.dart';

class Store {
  Store._();

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
    Hive.registerAdapter(ThemeAdapter());
    Hive.init(filesDir.path + "/hivedb");
    themeBox = await Hive.openBox<Theme>("themes");
    if (themeBox.isEmpty) {
      themeBox.addAll([
        Theme(
          id: 1,
          canDelete: false,
          autoMode: true,
          primaryColor: HexColor.fromHex("#3bc0c3").value,
          accentColor: HexColor.fromHex("#fe9b36").value,
          lightBackgroundColor: Colors.white.value,
          darkBackgroundColor: HexColor.fromHex("#293444").value,
          lightScaffoldBackgroundColor: HexColor.fromHex("#eef0f6").value,
          darkScaffoldBackgroundColor: HexColor.fromHex("#1c262f").value,
        ),
      ]);
    }
    themeConfig = await Hive.openBox("theme_config");
  }
}
