import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/store.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/index.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/model/theme_item.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/model/year_season.dart';

class MyHive {
  const MyHive._();

  static const int THEME_ITEM = 1;

  static const int MIAKN_BANGUMI = 2;
  static const int MIAKN_BANGUMI_ROW = 3;
  static const int MIAKN_CAROUSEL = 4;
  static const int MIAKN_INDEX = 5;
  static const int MIAKN_USER = 6;
  static const int MIAKN_SUBGROUP = 7;
  static const int MIAKN_SEASON = 8;
  static const int MIAKN_YEARSEASON = 9;
  static const int MIAKN_RECORD_ITEM = 10;
  static const int MIAKN_ITEM_LOCATION = 11;

  static late Box<ThemeItem> themeItemBox;
  static late Box<Index> indexBox;
  static late Box db;

  static init() async {
    Hive.init("${Store.filesDir.path}${Platform.pathSeparator}hivedb");
    Hive.registerAdapter(ThemeItemAdapter());
    Hive.registerAdapter(BangumiAdapter());
    Hive.registerAdapter(BangumiRowAdapter());
    Hive.registerAdapter(CarouselAdapter());
    Hive.registerAdapter(IndexAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(SubgroupAdapter());
    Hive.registerAdapter(SeasonAdapter());
    Hive.registerAdapter(YearSeasonAdapter());
    Hive.registerAdapter(RecordItemAdapter());

    themeItemBox = await Hive.openBox<ThemeItem>(HiveBoxKey.THEMES);
    if (themeItemBox.isEmpty) {
      final ThemeItem defaultTheme = ThemeItem()
        ..id = 1
        ..canDelete = false
        ..autoMode = true
        ..isDark = false
        ..primaryColor = HexColor.fromHex("#3bc0c3").value
        ..accentColor = HexColor.fromHex("#fe9b36").value
        ..lightBackgroundColor = Colors.white.value
        ..darkBackgroundColor = HexColor.fromHex("#293444").value
        ..lightScaffoldBackgroundColor = HexColor.fromHex("#f1f2f7").value
        ..darkScaffoldBackgroundColor = HexColor.fromHex("#1c262f").value;
      themeItemBox.add(defaultTheme);
    }
    db = await Hive.openBox("DB");
  }
}

class HiveDBKey {
  static const String THEME_ID = "THEME_ID";
  static const String MIKAN_INDEX = "MIKAN_INDEX";
  static const String MIKAN_OVA = "MIKAN_OVA";
}

class HiveBoxKey {
  static const String THEMES = "KEY_THEMES";
  static const String LOGIN = "KEY_LOGIN";
}
