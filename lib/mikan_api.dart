import 'dart:convert';

import 'package:fjs/fjs.dart';
import 'package:flutter/services.dart';

import 'shared/internal/hive.dart';
import 'shared/internal/log.dart';
import 'shared/models/announcement.dart';
import 'shared/models/bangumi.dart';
import 'shared/models/bangumi_details.dart';
import 'shared/models/bangumi_row.dart';
import 'shared/models/carousel.dart';
import 'shared/models/index.dart';
import 'shared/models/record_details.dart';
import 'shared/models/record_item.dart';
import 'shared/models/search.dart';
import 'shared/models/season.dart';
import 'shared/models/season_gallery.dart';
import 'shared/models/subgroup.dart';
import 'shared/models/subgroup_bangumi.dart';
import 'shared/models/user.dart';
import 'shared/models/year_season.dart';

/// Mikan API
class MikanApi {
  MikanApi._();

  static late JsEngine _engine;

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      await LibFjs.init();

      final api = await rootBundle.load('assets/js/api.js');

      final runtime = await JsAsyncRuntime.withOptions(
        builtin: const JsBuiltinOptions(fetch: true, url: true, console: true),
        additional: [JsModule(name: 'mikan', source: JsCode.bytes(api.buffer.asUint8List()))],
      );

      final context = await JsAsyncContext.from(runtime: runtime);
      _engine = JsEngine(context: context);
      await _engine.init(
        bridge: (v) async {
          try {
            final res = await _handleBridgeCall(v);
            return JsResult.ok(res ?? const JsValue.none());
          } catch (e) {
            return JsResult.err(JsError.generic(e.toString()));
          }
        },
      );
      _initialized = true;
    } catch (e, stackTrace) {
      Log.e(error: e, stackTrace: stackTrace, msg: 'MikanApi.init failed');
      rethrow;
    }
  }

  /// Convert Map<dynamic, dynamic> to Map<String, dynamic> recursively
  static Map<String, dynamic> _convertMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      final stringKey = key.toString();
      final dynamic convertedValue;
      if (value is Map) {
        convertedValue = _convertMap(value);
      } else if (value is List) {
        convertedValue = _convertList(value);
      } else {
        convertedValue = value;
      }
      return MapEntry(stringKey, convertedValue);
    });
  }

  /// Convert List<dynamic> with nested maps
  static List<dynamic> _convertList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return _convertMap(item);
      } else if (item is List) {
        return _convertList(item);
      }
      return item;
    }).toList();
  }

  /// Bridge call handler for cookie management
  static Future<JsValue?> _handleBridgeCall(JsValue value) async {
    try {
      final rawData = value.value;

      if (rawData is! Map) {
        return null;
      }

      final data = _convertMap(rawData);
      final action = data['action']?.toString();

      switch (action) {
        case 'saveCookie':
          final domain = data['domain']?.toString();
          final cookie = data['cookie'];
          if (cookie is Map<String, dynamic>) {
            await _saveCookie(domain!, cookie);
          }
          return null;
        case 'saveCookieHeader':
          final domain = data['domain']?.toString();
          final header = data['header']?.toString();
          if (domain != null && header != null) {
            await MyHive.saveCookieFromSetCookieHeader(domain, header);
          }
          return null;
        case 'getCookies':
          final domain = data['domain']?.toString();
          if (domain != null) {
            final cookies = _getCookies(domain);
            // Convert List<Map<String, dynamic>> to List<Map<dynamic, dynamic>> for JS
            final jsCookies = cookies.map((cookie) {
              final jsCookie = <dynamic, dynamic>{};
              cookie.forEach((key, value) {
                jsCookie[key] = value;
              });
              return jsCookie;
            }).toList();
            return JsValue.from(jsCookies);
          }
          return JsValue.from([]);
        case 'loadCookies':
          final loadDomain = data['domain']?.toString();
          if (loadDomain != null) {
            final cookieString = MyHive.getCookiesForRequest(loadDomain);
            // Return the Cookie header string directly
            return JsValue.from(cookieString ?? '');
          }
          return JsValue.from('');
        case 'clearCookies':
          final clearDomain = data['domain']?.toString();
          if (clearDomain != null) {
            await MyHive.clearCookies(clearDomain);
          }
          return null;
      }
    } catch (e, stackTrace) {
      Log.e(error: e, stackTrace: stackTrace, msg: '_handleBridgeCall failed');
      rethrow;
    }
    return null;
  }

  static Future<void> _saveCookie(String domain, Map<String, dynamic> cookie) async {
    final cookies = Map<String, dynamic>.from(MyHive.getCookies(domain));
    cookies[cookie['name'] as String] = cookie;
    await MyHive.saveCookies(domain, cookies);
  }

  static List<Map<String, dynamic>> _getCookies(String domain) {
    final cookies = MyHive.getCookies(domain);
    final result = cookies.values.map((e) => Map<String, dynamic>.from(e)).toList();
    return result;
  }

  static Future<T> _call<T>(String method, [List<Object?>? args]) async {
    try {
      await init();

      // Set baseUrl before each API call
      final mirrorUrl = MyHive.getMirrorUrl();
      final a = jsonEncode(args ?? []);
      final code =
          '''
        await (async () => {
          const {default: mikan} = await import("mikan");
          mikan.setBaseUrl('$mirrorUrl');
          return mikan["$method"].apply(mikan, $a);
        })()
      ''';

      final result = await _engine.eval(source: JsCode.code(code));
      return result.value as T;
    } catch (e, stackTrace) {
      Log.e(error: e, stackTrace: stackTrace, msg: 'MikanApi.$method failed');
      rethrow;
    }
  }

  // ==================== Converters ====================

  static Index _parseIndex(Map<String, dynamic> json) {
    return Index(
      years: (json['years'] as List).map((e) => _parseYearSeason(e as Map<String, dynamic>)).toList(),
      bangumiRows: (json['bangumiRows'] as List).map((e) => _parseBangumiRow(e as Map<String, dynamic>)).toList(),
      rss: Map.from(json['rss'] as Map).map(
        (k, v) => MapEntry(k as String, (v as List).map((e) => _parseRecordItem(e as Map<String, dynamic>)).toList()),
      ),
      carousels: (json['carousels'] as List).map((e) => _parseCarousel(e as Map<String, dynamic>)).toList(),
      user: json['user'] != null ? _parseUser(json['user'] as Map<String, dynamic>) : null,
      announcements: json['announcements'] != null
          ? (json['announcements'] as List).map((e) => _parseAnnouncement(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  static BangumiRow _parseBangumiRow(Map<String, dynamic> json) {
    return BangumiRow()
      ..name = json['name'] as String
      ..sname = json['sname'] as String
      ..num = json['num'] as int
      ..updatedNum = json['updatedNum'] as int
      ..subscribedNum = json['subscribedNum'] as int
      ..subscribedUpdatedNum = json['subscribedUpdatedNum'] as int
      ..bangumis = (json['bangumis'] as List).map((e) => _parseBangumi(e as Map<String, dynamic>)).toList();
  }

  static Bangumi _parseBangumi(Map<String, dynamic> json) {
    return Bangumi()
      ..id = json['id'] as String
      ..cover = json['cover'] as String
      ..name = json['name'] as String
      ..subscribed = json['subscribed'] as bool
      ..grey = json['grey'] as bool
      ..num = json['num'] as int?
      ..updateAt = json['updateAt'] as String
      ..week = json['week'] as String;
  }

  static RecordItem _parseRecordItem(Map<String, dynamic> json) {
    return RecordItem()
      ..id = json['id'] as String?
      ..name = json['name'] as String? ?? ''
      ..cover = json['cover'] as String? ?? ''
      ..title = json['title'] as String? ?? ''
      ..publishAt = json['publishAt'] as String? ?? ''
      ..groups = (json['groups'] as List?)?.map((e) => _parseSubgroup(e as Map<String, dynamic>)).toList() ?? []
      ..url = json['url'] as String? ?? ''
      ..magnet = json['magnet'] as String? ?? ''
      ..size = json['size'] as String? ?? ''
      ..torrent = json['torrent'] as String? ?? ''
      ..tags = (json['tags'] as List?)?.map((e) => e as String).toList() ?? [];
  }

  static Subgroup _parseSubgroup(Map<String, dynamic> json) {
    return Subgroup(id: json['id'] as String?, name: json['name'] as String);
  }

  static User _parseUser(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      token: json['token'] as String?,
      rss: json['rss'] as String?,
    );
  }

  static SearchResult _parseSearch(Map<String, dynamic> json) {
    return SearchResult(
      bangumis: (json['bangumis'] as List).map((e) => _parseBangumi(e as Map<String, dynamic>)).toList(),
      subgroups: (json['subgroups'] as List).map((e) => _parseSubgroup(e as Map<String, dynamic>)).toList(),
      records: (json['records'] as List).map((e) => _parseRecordItem(e as Map<String, dynamic>)).toList(),
    );
  }

  static SeasonGallery _parseSeasonGallery(Map<String, dynamic> json) {
    final title = json['title'] as String;
    final parts = title.split(' ');
    return SeasonGallery(
      year: parts.isNotEmpty ? parts.first : '',
      season: parts.length > 1 ? parts.sublist(1).join(' ') : '',
      title: title,
      active: json['active'] as bool,
      bangumis: (json['bangumis'] as List).map((e) => _parseBangumi(e as Map<String, dynamic>)).toList(),
    );
  }

  static BangumiDetail _parseBangumiDetail(Map<String, dynamic> json) {
    final subgroupBangumis = <String, SubgroupBangumi>{};
    (json['subgroupBangumis'] as Map<String, dynamic>).forEach((key, value) {
      subgroupBangumis[key] = _parseSubgroupBangumi(value as Map<String, dynamic>);
    });
    return BangumiDetail()
      ..id = json['id'] as String
      ..cover = json['cover'] as String
      ..name = json['name'] as String
      ..intro = json['intro'] as String
      ..subscribed = json['subscribed'] as bool
      ..more = Map<String, String>.from(json['more'] as Map)
      ..subgroupBangumis = subgroupBangumis;
  }

  static SubgroupBangumi _parseSubgroupBangumi(Map<String, dynamic> json) {
    return SubgroupBangumi()
      ..dataId = json['dataId'] as String
      ..name = json['name'] as String
      ..subscribed = json['subscribed'] as bool
      ..sublang = json['sublang'] as String?
      ..rss = json['rss'] as String?
      ..state = json['state'] as int
      ..subgroups = (json['subgroups'] as List).map((e) => _parseSubgroup(e as Map<String, dynamic>)).toList()
      ..records = (json['records'] as List).map((e) => _parseRecordItem(e as Map<String, dynamic>)).toList();
  }

  static Carousel _parseCarousel(Map<String, dynamic> json) {
    return Carousel()
      ..id = json['id'] as String
      ..cover = json['cover'] as String;
  }

  static YearSeason _parseYearSeason(Map<String, dynamic> json) {
    return YearSeason()
      ..year = json['year'] as String
      ..seasons = (json['seasons'] as List).map((e) => _parseSeason(e as Map<String, dynamic>)).toList();
  }

  static Season _parseSeason(Map<String, dynamic> json) {
    return Season(
      year: json['year'] as String,
      season: json['season'] as String,
      title: json['title'] as String,
      active: json['active'] as bool,
    );
  }

  static Announcement _parseAnnouncement(Map<String, dynamic> json) {
    return Announcement(
      date: json['date'] as String,
      nodes: (json['nodes'] as List).map((e) => _parseAnnouncementNode(e as Map<String, dynamic>)).toList(),
    );
  }

  static AnnouncementNode _parseAnnouncementNode(Map<String, dynamic> json) {
    return AnnouncementNode(
      text: json['text'] as String,
      type: json['type'] as String?,
      place: json['place'] as String?,
    );
  }

  static RecordDetail _parseRecordDetail(Map<String, dynamic> json) {
    return RecordDetail()
      ..id = json['id'] as String? ?? ''
      ..cover = json['cover'] as String? ?? ''
      ..name = json['name'] as String? ?? ''
      ..title = json['title'] as String? ?? ''
      ..tags = (json['tags'] as List?)?.map((e) => e as String).toList() ?? []
      ..subscribed = json['subscribed'] as bool? ?? false
      ..more = Map<String, String>.from(json['more'] as Map? ?? {})
      ..intro = json['intro'] as String? ?? ''
      ..torrent = json['torrent'] as String? ?? ''
      ..magnet = json['magnet'] as String? ?? '';
  }

  // ==================== API Methods ====================

  static Future<Index> index([String? year, String? seasonStr]) async {
    final result = await _call<Map<String, dynamic>>('index', [year, seasonStr]);
    return _parseIndex(result);
  }

  static Future<List<BangumiRow>> season(String year, String seasonStr) async {
    final result = await _call<List>('season', [year, seasonStr]);
    return result.map((e) => _parseBangumiRow(e as Map<String, dynamic>)).toList();
  }

  static Future<List<RecordItem>> day([int predate = 0, int enddate = 1]) async {
    final result = await _call<List>('day', [predate, enddate]);
    return result.map((e) => _parseRecordItem(e as Map<String, dynamic>)).toList();
  }

  static Future<SearchResult> search(String searchstr, {String? subgroupid, int page = 1}) async {
    final result = await _call<Map<String, dynamic>>('search', [searchstr, subgroupid, page]);
    return _parseSearch(result);
  }

  static Future<List<RecordItem>> list([int page = 1]) async {
    final result = await _call<List>('list', [page]);
    return result.map((e) => _parseRecordItem(e as Map<String, dynamic>)).toList();
  }

  static Future<List<SeasonGallery>> subgroup(String subgroupId) async {
    final result = await _call<List>('subgroup', [subgroupId]);
    return result.map((e) => _parseSeasonGallery(e as Map<String, dynamic>)).toList();
  }

  static Future<BangumiDetail> bangumi(String bangumiId) async {
    final result = await _call<Map<String, dynamic>>('bangumi', [bangumiId]);
    return _parseBangumiDetail(result);
  }

  static Future<List<RecordItem>> bangumiMore(String bangumiId, String subtitleGroupId, {int take = 65}) async {
    final result = await _call<List>('bangumiMore', [bangumiId, subtitleGroupId, take]);
    return result.map((e) => _parseRecordItem(e as Map<String, dynamic>)).toList();
  }

  static Future<RecordDetail> details(String episodeId) async {
    final result = await _call<Map<String, dynamic>>('details', [episodeId]);
    return _parseRecordDetail(result);
  }

  static Future<List<Bangumi>> mySubscribed() async {
    final result = await _call<List>('mySubscribed');
    return result.map((e) => _parseBangumi(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Bangumi>> mySubscribedSeasonBangumi(String year, String seasonStr) async {
    final result = await _call<List>('mySubscribedSeasonBangumi', [year, seasonStr]);
    return result.map((e) => _parseBangumi(e as Map<String, dynamic>)).toList();
  }

  static Future<User?> getUser() async {
    final result = await _call<Map<String, dynamic>?>('getUser');
    return result != null ? _parseUser(result) : null;
  }

  static Future<void> clearCookies() async {
    await _call('clearCookies');
  }

  static Future<String> login(String email, String password, {String? returnUrl}) async {
    return _call('login', [email, password, returnUrl]);
  }

  static Future<String> subscribeBangumi(String bangumiId, {String? subtitleGroupId}) async {
    return _call('subscribeBangumi', [bangumiId, subtitleGroupId]);
  }

  static Future<String> unsubscribeBangumi(String bangumiId, {String? subtitleGroupId}) async {
    return _call('unsubscribeBangumi', [bangumiId, subtitleGroupId]);
  }

  static Future<dynamic> release() async {
    return _call('release');
  }

  static Future<List<dynamic>> fonts() async {
    return _call('fonts');
  }

  static Future<String> register(String email, String password, String confirmPassword) async {
    return _call('register', [email, password, confirmPassword]);
  }

  static Future<String> forgotPassword(String email) async {
    return _call('forgotPassword', [email]);
  }

  static Future<List<RecordItem>> ova() async {
    return _call('ova');
  }

  // NEVER CALL THIS METHOD OUTSIDE!!!
  static Future<void> dispose() async {
    await _engine.dispose();
    _initialized = false;
  }
}
