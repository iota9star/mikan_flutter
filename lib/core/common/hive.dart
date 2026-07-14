import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mikan/hive_registrar.g.dart';
import 'package:mikan/core/common/consts.dart';

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
  static const int mikanAnnouncement = mikanRecordItem + 1;
  static const int mikanAnnouncementNode = mikanAnnouncement + 1;

  static late final Box settings;
  static late final Box db;

  static Future<void> init() async {
    await Future.wait([
      getTemporaryDirectory().then((value) => cacheDir = value),
      getApplicationSupportDirectory().then((value) => filesDir = value),
    ]);
    cookiesDir = '${filesDir.path}/cookies';
    final directory = Directory(cookiesDir);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    Hive.init('${filesDir.path}${Platform.pathSeparator}hivedb');
    Hive.registerAdapters();
    db = await Hive.openBox(HiveBoxKey.db);
    settings = await Hive.openBox(HiveBoxKey.settings);
    MikanUrls.baseUrl = MyHive.getMirrorUrl();
  }

  static late final Directory cacheDir;
  static late final Directory filesDir;

  static late final String cookiesDir;

  /// Per-domain serialization locks for cookie read-modify-write cycles.
  /// Prevents concurrent writes from dropping each other's cookies.
  static final Map<String, Future<void>> _cookieLocks = {};

  static Future<T> _withCookieLock<T>(String domain, Future<T> Function() action) {
    final previous = _cookieLocks[domain] ?? Future<void>.value();
    final completer = Completer<void>();
    _cookieLocks[domain] = completer.future;
    return previous.then((_) => action()).whenComplete(() {
      if (_cookieLocks[domain] == completer.future) {
        _cookieLocks.remove(domain);
      }
      completer.complete();
    });
  }

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
    return db.get(HiveBoxKey.login, defaultValue: <String, dynamic>{}).cast<String, dynamic>();
  }

  static Future<void> saveCookies(String domain, Map<String, dynamic> cookies) async {
    await db.put('${HiveBoxKey.cookies}_$domain', cookies);
  }

  /// Atomically merges a single cookie into the store under a per-domain lock,
  /// preventing concurrent writes from dropping each other's cookies.
  static Future<void> saveCookie(String domain, String name, Map<String, dynamic> cookie) async {
    await _withCookieLock(domain, () async {
      final cookies = getCookies(domain);
      cookies[name] = cookie;
      await saveCookies(domain, cookies);
    });
  }

  static Map<String, dynamic> getCookies(String domain) {
    final cookies = db.get('${HiveBoxKey.cookies}_$domain', defaultValue: <String, dynamic>{});

    // Clean up any corrupted cookie entries (not Maps) in-memory. Persisting
    // the cleanup is handled by the next write through the serialization lock,
    // avoiding a fire-and-forget write that races with concurrent saves.
    final cleaned = <String, dynamic>{};

    cookies.forEach((key, value) {
      // Accept both Map<String, dynamic> and Map<dynamic, dynamic>
      if (value is Map) {
        // Convert to Map<String, dynamic>
        cleaned[key as String] = Map<String, dynamic>.from(value);
      }
    });

    return cleaned;
  }

  static String? getCookiesForRequest(String domain) {
    final cookies = getCookies(domain);
    final validCookies = <String>[];

    cookies.forEach((name, cookieData) {
      if (cookieData is! Map<String, dynamic>) {
        return;
      }

      final value = cookieData['value']?.toString() ?? '';
      final expiresStr = cookieData['expires']?.toString();

      // Check if cookie is expired
      if (expiresStr != null && expiresStr.isNotEmpty) {
        try {
          final expires = DateTime.parse(expiresStr);
          if (expires.isBefore(DateTime.now())) {
            // Cookie expired, skip it
            return;
          }
        } catch (e) {
          // Invalid date format, skip expiration check
        }
      }

      validCookies.add('$name=$value');
    });

    if (validCookies.isEmpty) {
      return null;
    }
    return validCookies.join('; ');
  }

  static Future<void> saveCookieFromSetCookieHeader(String domain, String setCookieHeader) async {
    await _withCookieLock(domain, () async {
      final cookie = Cookie.fromSetCookieValue(setCookieHeader);
      final cookies = getCookies(domain);

      // Convert Cookie to Map for storage
      final cookieMap = <String, dynamic>{'name': cookie.name, 'value': cookie.value};
      if (cookie.expires != null) {
        cookieMap['expires'] = cookie.expires!.toIso8601String();
      }
      if (cookie.maxAge != null) {
        cookieMap['maxAge'] = cookie.maxAge;
      }
      if (cookie.domain != null) {
        cookieMap['domain'] = cookie.domain;
      }
      if (cookie.path != null) {
        cookieMap['path'] = cookie.path;
      }
      if (cookie.secure) {
        cookieMap['secure'] = true;
      }
      if (cookie.httpOnly) {
        cookieMap['httpOnly'] = true;
      }

      // Parse SameSite attribute manually (not supported by Dart's Cookie class)
      final sameSiteMatch = RegExp(r'samesite\s*=\s*([a-zA-Z]+)', caseSensitive: false).firstMatch(setCookieHeader);
      if (sameSiteMatch != null) {
        cookieMap['sameSite'] = sameSiteMatch.group(1);
      }

      cookies[cookie.name] = cookieMap;
      await saveCookies(domain, cookies);
    });
  }

  static Future<void> removeCookies() async {
    final Directory dir = Directory(cookiesDir);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
    // Also remove cookies from Hive
    final keys = db.keys.toList();
    for (final key in keys) {
      if (key is String && key.startsWith('${HiveBoxKey.cookies}_')) {
        await db.delete(key);
      }
    }
  }

  static Future<void> clearCookies(String domain) async {
    await db.delete('${HiveBoxKey.cookies}_$domain');
  }

  static Future<void> clearCache() async {
    if (!cacheDir.existsSync()) {
      return;
    }
    final entities = cacheDir.listSync();
    await Future.wait([for (final entity in entities) entity.delete(recursive: true)]);
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
    return settings.put(SettingsHiveKey.fontFamily, font == null ? null : {'name': font.key, 'fontFamily': font.value});
  }

  static MapEntry<String, String>? getFontFamily() {
    final map = settings.get(SettingsHiveKey.fontFamily);
    if (map is! Map) {
      return null;
    }
    final name = map['name'];
    final fontFamily = map['fontFamily'];
    if (name is! String || fontFamily is! String) {
      return null;
    }
    return MapEntry(name, fontFamily);
  }

  static int getColorSeed() {
    return settings.get(SettingsHiveKey.colorSeed, defaultValue: Colors.green.toARGB32());
  }

  static Future<void> setColorSeed(Color color) {
    return settings.put(SettingsHiveKey.colorSeed, color.toARGB32());
  }

  static int getCardStyle() {
    return settings.get(SettingsHiveKey.cardStyle, defaultValue: 1);
  }

  static Future<void> setCardStyle(int style) {
    return settings.put(SettingsHiveKey.cardStyle, style);
  }

  static bool isDynamicColorEnabled() {
    return settings.get(SettingsHiveKey.dynamicColor, defaultValue: false);
  }

  static Future<void> setDynamicColorEnabled(bool enable) {
    return settings.put(SettingsHiveKey.dynamicColor, enable);
  }

  static ThemeMode getThemeMode() {
    final name = settings.get(SettingsHiveKey.themeMode);
    return ThemeMode.values.firstWhereOrNull((e) => e.name == name) ?? ThemeMode.system;
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final themeMode = getThemeMode();
    if (themeMode != mode) {
      await settings.put(SettingsHiveKey.themeMode, mode.name);
    }
  }

  static String getMirrorUrl() {
    return settings.get(SettingsHiveKey.mirrorUrl, defaultValue: MikanUrls.baseUrls.last);
  }

  static Future<void> setMirrorUrl(String url) {
    return settings.put(SettingsHiveKey.mirrorUrl, url);
  }

  static TabletMode getTabletMode() {
    final mode = settings.get(SettingsHiveKey.tabletMode, defaultValue: TabletMode.auto.name);
    return TabletMode.values.firstWhere((e) => e.name == mode);
  }

  static Future<void> setTabletMode(TabletMode mode) {
    return settings.put(SettingsHiveKey.tabletMode, mode.name);
  }

  static Decimal getCardRatio() {
    final value = settings.get(SettingsHiveKey.cardRatio, defaultValue: '0.9');
    return Decimal.parse(value);
  }

  static Future<void> setCardRatio(Decimal ratio) {
    return settings.put(SettingsHiveKey.cardRatio, ratio.toString());
  }

  static Decimal getCardWidth() {
    final value = settings.get(SettingsHiveKey.cardWidth, defaultValue: '200.0');
    return Decimal.parse(value);
  }

  static Future<void> setCardWidth(Decimal width) {
    return settings.put(SettingsHiveKey.cardWidth, width.toString());
  }
}

class HiveDBKey {
  const HiveDBKey._();

  static const String themeId = 'THEME_ID';
  static const String mikanIndex = 'MIKAN_INDEX';
  static const String mikanOva = 'MIKAN_OVA';
  static const String mikanSearch = 'MIKAN_SEARCH';
  static const String mikanList = 'MIKAN_LIST';
  static const String ignoreUpdateVersion = 'IGNORE_UPDATE_VERSION';
}

class HiveBoxKey {
  const HiveBoxKey._();

  static const String db = 'KEY_DB';
  static const String settings = 'KEY_SETTINGS';
  static const String login = 'KEY_LOGIN';
  static const String cookies = 'COOKIES';
}

class SettingsHiveKey {
  const SettingsHiveKey._();

  static const String colorSeed = 'COLOR_SEED';
  static const String fontFamily = 'FONT_FAMILY';
  static const String themeMode = 'THEME_MODE';
  static const String mirrorUrl = 'MIRROR_URL';
  static const String cardRatio = 'CARD_RATIO';
  static const String cardWidth = 'CARD_WIDTH';
  static const String cardStyle = 'CARD_STYLE';
  static const String tabletMode = 'TABLET_MODE';
  static const String dynamicColor = 'DYNAMIC_COLOR';
}

enum TabletMode {
  tablet('平板模式'),
  auto('自动'),
  disable('禁用');

  const TabletMode(this.label);

  final String label;

  bool get isTablet => this == TabletMode.tablet;

  bool get isAuto => this == TabletMode.auto;

  bool get isDisable => this == TabletMode.disable;
}
