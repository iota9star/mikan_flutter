import 'dart:io';

import 'package:dio/dio.dart';

import 'consts.dart';
import 'http.dart';

class Repo {
  const Repo._();

  static Future<Resp> season(String year, String season) {
    final parameters = {'year': year, 'seasonStr': season};
    final extra = {'$MikanFunc': MikanFunc.season};
    final Options options = Options(
      extra: extra,
    );
    return Http.get(
      MikanUrls.seasonUpdate,
      queryParameters: parameters,
      options: options,
    );
  }

  static Future<Resp> day(int pre, int end) {
    final parameters = {'predate': pre, 'enddate': end, 'maximumitems': 16};
    final extra = {'$MikanFunc': MikanFunc.day};
    final Options options = Options(extra: extra);
    return Http.get(
      MikanUrls.dayUpdate,
      queryParameters: parameters,
      options: options,
    );
  }

  static Future<Resp> ova() {
    return day(-1, -1);
  }

  static Future<Resp> search(
    String? keywords, {
    String? subgroupId,
  }) {
    final parameters = {'searchstr': keywords, 'subgroupid': subgroupId};
    final extra = {'$MikanFunc': MikanFunc.search};
    final Options options = Options(extra: extra);
    return Http.get(
      MikanUrls.search,
      queryParameters: parameters,
      options: options,
    );
  }

  static Future<Resp> list(int? page) {
    final extra = {'$MikanFunc': MikanFunc.list};
    final Options options = Options(extra: extra);
    return Http.get("${MikanUrls.list}/${page ?? ""}", options: options);
  }

  static Future<Resp> index() {
    final extra = {'$MikanFunc': MikanFunc.index};
    final Options options = Options(extra: extra);
    return Http.get(MikanUrls.baseUrl, options: options);
  }

  static Future<Resp> subgroup(String? subgroupId) {
    final extra = {'$MikanFunc': MikanFunc.subgroup};
    final Options options = Options(extra: extra);
    return Http.get(
      '${MikanUrls.subgroup}/$subgroupId',
      options: options,
    );
  }

  static Future<Resp> bangumi(String id) {
    final extra = {'$MikanFunc': MikanFunc.bangumi};
    final Options options = Options(extra: extra);
    return Http.get('${MikanUrls.bangumi}/$id', options: options);
  }

  static Future<Resp> bangumiMore(
    String bangumiId,
    String subgroupId,
    int take,
  ) {
    final extra = {'$MikanFunc': MikanFunc.bangumiMore};
    final Options options = Options(extra: extra);
    return Http.get(
      MikanUrls.bangumiMore,
      queryParameters: {
        'bangumiId': bangumiId,
        'subtitleGroupId': subgroupId,
        'take': take,
      },
      options: options,
    );
  }

  static Future<Resp> details(String url) {
    final extra = {'$MikanFunc': MikanFunc.details};
    final Options options = Options(extra: extra);
    return Http.get(url, options: options);
  }

  static Future<Resp> subscribeBangumi(
    int bangumiId,
    bool subscribe, {
    int? subgroupId,
    // 1: 简中，2: 繁中
    int? language,
  }) {
    final options = Options(
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
    return Http.json(
      (subscribe ? MikanUrls.unsubscribeBangumi : MikanUrls.subscribeBangumi),
      data: <String, dynamic>{
        'BangumiID': bangumiId,
        'SubtitleGroupID': subgroupId,
        if (language != null) 'Language': language,
      },
      options: options,
    );
  }

  static Future<Resp> mySubscribedSeasonBangumi(
    String year,
    String season,
  ) {
    final Options options = Options(
      extra: {'$MikanFunc': MikanFunc.subscribedSeason},
    );
    return Http.get(
      MikanUrls.subscribedSeason,
      queryParameters: <String, dynamic>{
        'year': year,
        'seasonStr': season,
      },
      options: options,
    );
  }

  static Future<Resp> login(Map<String, dynamic> params) {
    final Options options = Options(
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.plain,
    );
    return Http.form(
      MikanUrls.login,
      queryParameters: {'ReturnUrl': '/'},
      data: params,
      options: options,
    );
  }

  static Future<Resp> register(Map<String, dynamic> params) {
    final Options options = Options(
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.plain,
    );
    return Http.form(
      MikanUrls.register,
      data: params,
      options: options,
    );
  }

  static Future<Resp> forgotPassword(Map<String, dynamic> params) {
    final Options options = Options(
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.plain,
    );
    return Http.form(
      MikanUrls.forgotPassword,
      data: params,
      options: options,
    );
  }

  static Future<Resp> refreshLoginToken() {
    final Options options = Options(
      extra: {'$MikanFunc': MikanFunc.refreshLoginToken},
    );
    return Http.get(
      MikanUrls.mySubscribed,
      options: options,
    );
  }

  static Future<Resp> refreshForgotPasswordToken() {
    final Options options = Options(
      extra: {'$MikanFunc': MikanFunc.refreshForgotPasswordToken},
    );
    return Http.get(
      MikanUrls.forgotPassword,
      options: options,
    );
  }

  static Future<Resp> refreshRegisterToken() {
    final Options options = Options(
      extra: {'$MikanFunc': MikanFunc.refreshRegisterToken},
    );
    return Http.get(
      MikanUrls.register,
      options: options,
    );
  }

  static Future<Resp> fonts() {
    final Options options = Options(
      extra: {'$ExtraUrl': ExtraUrl.fontsManifest},
      contentType: ContentType.json.toString(),
    );
    return Http.get(ExtraUrl.fontsManifest, options: options);
  }

  static Future<Resp> release() {
    return Http.get(ExtraUrl.releaseVersion);
  }
}
