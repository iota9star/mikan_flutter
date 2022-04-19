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

  static const int themeItem = 1;

  static const int mikanBangumi = themeItem + 1;
  static const int mikanBangumiRow = mikanBangumi + 1;
  static const int mikanCarousel = mikanBangumiRow + 1;
  static const int mikanIndex = mikanCarousel + 1;
  static const int mikanUser = mikanIndex + 1;
  static const int mikanSubgroup = mikanUser + 1;
  static const int mikanSeason = mikanSubgroup + 1;
  static const int mikanYearSeason = mikanSeason + 1;
  static const int mikanRecordItem = mikanYearSeason + 1;

  static late Box<ThemeItem> themeItemBox;
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

    themeItemBox = await Hive.openBox<ThemeItem>(HiveBoxKey.themes);
    if (themeItemBox.isEmpty) {
      final ThemeItem defaultTheme = ThemeItem()
        ..id = 1
        ..canDelete = false
        ..autoMode = true
        ..isDark = false
        ..primaryColor = HexColor.fromHex("#39c7a5").value
        ..accentColor = HexColor.fromHex("#f94800").value
        ..lightBackgroundColor = Colors.white.value
        ..darkBackgroundColor = HexColor.fromHex("#132149").value
        ..lightScaffoldBackgroundColor = HexColor.fromHex("#f1f2f7").value
        ..darkScaffoldBackgroundColor = HexColor.fromHex("#000000").value;
      themeItemBox.add(defaultTheme);
    }
    db = await Hive.openBox(HiveBoxKey.db);
  }
}

class HiveDBKey {
  const HiveDBKey._();

  static const String themeId = "THEME_ID";
  static const String mikanIndex = "MIKAN_INDEX";
  static const String mikanOva = "MIKAN_OVA";
  static const String mikanSearch = "MIKAN_SEARCH";
  static const String ignoreUpdateVersion = "IGNORE_UPDATE_VERSION";
}

class HiveBoxKey {
  const HiveBoxKey._();

  static const String db = "KEY_DB";
  static const String themes = "KEY_THEMES";
  static const String login = "KEY_LOGIN";
}
