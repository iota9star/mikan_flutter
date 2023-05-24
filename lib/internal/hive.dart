import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../model/bangumi.dart';
import '../model/bangumi_row.dart';
import '../model/carousel.dart';
import '../model/index.dart';
import '../model/record_item.dart';
import '../model/season.dart';
import '../model/subgroup.dart';
import '../model/user.dart';
import '../model/year_season.dart';
import 'consts.dart';

class MyHive {
  const MyHive._();

  static const int _base = 1;

  static const int mikanBangumi = _base + 1;
  static const int mikanBangumiRow = mikanBangumi + 1;
  static const int mikanCarousel = mikanBangumiRow + 1;
  static const int mikanIndex = mikanCarousel + 1;
  static const int mikanUser = mikanIndex + 1;
  static const int mikanSubgroup = mikanUser + 1;
  static const int mikanSeason = mikanSubgroup + 1;
  static const int mikanYearSeason = mikanSeason + 1;
  static const int mikanRecordItem = mikanYearSeason + 1;

  static late final Box settings;
  static late final Box db;

  static Future<void> init() async {
    await Future.wait([
      getTemporaryDirectory().then((value) => cacheDir = value),
      getApplicationSupportDirectory().then((value) => filesDir = value),
    ]);
    cookiesPath = '${filesDir.path}/cookies';
    final directory = Directory(cookiesPath);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    Hive.init('${filesDir.path}${Platform.pathSeparator}hivedb');
    Hive.registerAdapter(BangumiAdapter());
    Hive.registerAdapter(BangumiRowAdapter());
    Hive.registerAdapter(CarouselAdapter());
    Hive.registerAdapter(IndexAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(SubgroupAdapter());
    Hive.registerAdapter(SeasonAdapter());
    Hive.registerAdapter(YearSeasonAdapter());
    Hive.registerAdapter(RecordItemAdapter());
    db = await Hive.openBox(HiveBoxKey.db);
    settings = await Hive.openBox(HiveBoxKey.settings);
    MikanUrls.baseUrl = MyHive.getMirrorUrl();
  }

  static late final Directory cacheDir;
  static late final Directory filesDir;

  static late final String cookiesPath;

  static const int KB = 1024;
  static const int MB = 1024 * KB;
  static const int GB = 1024 * MB;

  static void setLogin(Map<String, dynamic> login) {
    db.put(HiveBoxKey.login, login);
  }

  static Future<void> removeLogin() async {
    await db.delete(HiveBoxKey.login);
  }

  static Map<String, dynamic> getLogin() {
    return db.get(
      HiveBoxKey.login,
      defaultValue: <String, dynamic>{},
    ).cast<String, dynamic>();
  }

  static Future<void> removeCookies() async {
    final Directory dir = Directory(cookiesPath);
    if (dir.existsSync()) {
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

  static Future<void> setFontFamily(MapEntry<String, String>? font) {
    return settings.put(
      SettingsHiveKey.fontFamily,
      font == null ? null : {'name': font.key, 'fontFamily': font.value},
    );
  }

  static MapEntry<String, String>? getFontFamily() {
    final map = settings.get(SettingsHiveKey.fontFamily);
    if (map == null) {
      return null;
    }
    return MapEntry(map['name'], map['fontFamily']);
  }

  static int getColorSeed() {
    return settings.get(
      SettingsHiveKey.colorSeed,
      defaultValue: Colors.green.value,
    );
  }

  static Future<void> setColorSeed(Color color) {
    return settings.put(SettingsHiveKey.colorSeed, color.value);
  }

  static bool dynamicColorEnabled() {
    return settings.get(
      SettingsHiveKey.dynamicColor,
      defaultValue: false,
    );
  }

  static Future<void> enableDynamicColor(bool enable) {
    return settings.put(SettingsHiveKey.dynamicColor, enable);
  }

  static ThemeMode getThemeMode() {
    final name = settings.get(SettingsHiveKey.themeMode);
    return ThemeMode.values.firstWhereOrNull((e) => e.name == name) ??
        ThemeMode.system;
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final themeMode = getThemeMode();
    if (themeMode != mode) {
      await settings.put(SettingsHiveKey.themeMode, mode.name);
    }
  }

  static String getMirrorUrl() {
    return settings.get(
      SettingsHiveKey.mirrorUrl,
      defaultValue: MikanUrls.baseUrls.first,
    );
  }

  static Future<void> setMirrorUrl(String url) {
    return settings.put(SettingsHiveKey.mirrorUrl, url);
  }

  static TabletMode getTabletMode() {
    final mode = settings.get(
      SettingsHiveKey.tabletMode,
      defaultValue: TabletMode.auto.name,
    );
    return TabletMode.values.firstWhere((e) => e.name == mode);
  }

  static Future<void> setTabletMode(TabletMode mode) {
    return settings.put(SettingsHiveKey.tabletMode, mode.name);
  }

  static double getCardRatio() {
    final value = settings.get(
      SettingsHiveKey.cardRatio,
      defaultValue: '0.9',
    );
    return double.parse(value);
  }

  static Future<void> setCardRatio(double ratio) {
    return settings.put(SettingsHiveKey.cardRatio, ratio.toString());
  }
}

class HiveDBKey {
  const HiveDBKey._();

  static const String themeId = 'THEME_ID';
  static const String mikanIndex = 'MIKAN_INDEX';
  static const String mikanOva = 'MIKAN_OVA';
  static const String mikanSearch = 'MIKAN_SEARCH';
  static const String ignoreUpdateVersion = 'IGNORE_UPDATE_VERSION';
}

class HiveBoxKey {
  const HiveBoxKey._();

  static const String db = 'KEY_DB';
  static const String settings = 'KEY_SETTINGS';
  static const String login = 'KEY_LOGIN';
}

class SettingsHiveKey {
  const SettingsHiveKey._();

  static const String colorSeed = 'COLOR_SEED';
  static const String fontFamily = 'FONT_FAMILY';
  static const String themeMode = 'THEME_MODE';
  static const String mirrorUrl = 'MIRROR_URL';
  static const String cardRatio = 'CARD_RATIO';
  static const String tabletMode = 'TABLET_MODE';
  static const String dynamicColor = 'DYNAMIC_COLOR';
}

enum TabletMode {
  tablet('平板模式'),
  auto('自动'),
  disable('禁用'),
  ;

  const TabletMode(this.label);

  final String label;

  bool get isTablet => this == TabletMode.tablet;

  bool get isAuto => this == TabletMode.auto;

  bool get isDisable => this == TabletMode.disable;
}
