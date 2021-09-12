import 'package:dio/dio.dart';
import 'package:mikan_flutter/internal/consts.dart';
import 'package:mikan_flutter/internal/http.dart';

class Repo {
  const Repo._();

  static Future<Resp> season(final String year, final String season) async {
    final parameters = {"year": year, "seasonStr": season};
    final extra = {"$MikanFunc": MikanFunc.season};
    final Options options = Options(extra: extra);
    return await Http.get(
      MikanUrl.seasonUpdate,
      queryParameters: parameters,
      options: options,
    );
  }

  static Future<Resp> day(final int pre, final int end) async {
    final parameters = {"predate": pre, "enddate": end, "maximumitems": 16};
    final extra = {"$MikanFunc": MikanFunc.day};
    final Options options = Options(extra: extra);
    return await Http.get(
      MikanUrl.dayUpdate,
      queryParameters: parameters,
      options: options,
    );
  }

  static Future<Resp> ova() async {
    return await day(-1, -1);
  }

  static Future<Resp> search(
    final String? keywords, {
    final String? subgroupId,
  }) async {
    final parameters = {"searchstr": keywords, "subgroupid": subgroupId};
    final extra = {"$MikanFunc": MikanFunc.search};
    final Options options = Options(extra: extra);
    return await Http.get(
      MikanUrl.search,
      queryParameters: parameters,
      options: options,
    );
  }

  static Future<Resp> list(final int? page) async {
    final extra = {"$MikanFunc": MikanFunc.list};
    final Options options = Options(extra: extra);
    return await Http.get("${MikanUrl.list}/${page ?? ""}", options: options);
  }

  static Future<Resp> index() async {
    final extra = {"$MikanFunc": MikanFunc.index};
    final Options options = Options(extra: extra);
    return await Http.get(MikanUrl.baseUrl, options: options);
  }

  static Future<Resp> subgroup(final String? subgroupId) async {
    final extra = {"$MikanFunc": MikanFunc.subgroup};
    final Options options = Options(extra: extra);
    return await Http.get("${MikanUrl.subgroup}/$subgroupId", options: options);
  }

  static Future<Resp> bangumi(final String id) async {
    final extra = {"$MikanFunc": MikanFunc.bangumi};
    final Options options = Options(extra: extra);
    return await Http.get("${MikanUrl.bangumi}/$id", options: options);
  }

  static Future<Resp> bangumiMore(
    final String bangumiId,
    final String subgroupId,
    final int take,
  ) async {
    final extra = {"$MikanFunc": MikanFunc.bangumiMore};
    final Options options = Options(extra: extra);
    return await Http.get(
      MikanUrl.bangumiMore,
      queryParameters: {
        "bangumiId": bangumiId,
        "subtitleGroupId": subgroupId,
        "take": take,
      },
      options: options,
    );
  }

  static Future<Resp> details(final String url) async {
    final extra = {"$MikanFunc": MikanFunc.details};
    final Options options = Options(extra: extra);
    return await Http.get(url, options: options);
  }

  static Future<Resp> subscribeBangumi(
    final int bangumiId,
    final bool subscribe, {
    final int? subgroupId,
  }) async {
    final Options options = Options(
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
    return await Http.postJSON(
      subscribe ? MikanUrl.unsubscribeBangumi : MikanUrl.subscribeBangumi,
      data: <String, dynamic>{
        "BangumiID": bangumiId,
        "SubtitleGroupID": subgroupId,
      },
      options: options,
    );
  }

  static Future<Resp> mySubscribedSeasonBangumi(
      final String year, final String season) async {
    final Options options = Options(
      extra: {"$MikanFunc": MikanFunc.subscribedSeason},
    );
    return await Http.get(
      MikanUrl.subscribedSeason,
      queryParameters: <String, dynamic>{
        "year": year,
        "seasonStr": season,
      },
      options: options,
    );
  }

  static Future<Resp> login(final Map<String, dynamic> params) async {
    final Options options = Options(
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.plain,
    );
    return await Http.postForm(
      MikanUrl.login,
      queryParameters: {"ReturnUrl": "/"},
      data: params,
      options: options,
    );
  }

  static Future<Resp> register(final Map<String, dynamic> params) async {
    final Options options = Options(
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.plain,
    );
    return await Http.postForm(
      MikanUrl.register,
      data: params,
      options: options,
    );
  }

  static Future<Resp> forgotPassword(final Map<String, dynamic> params) async {
    final Options options = Options(
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.plain,
    );
    return await Http.postForm(
      MikanUrl.forgotPassword,
      data: params,
      options: options,
    );
  }

  static Future<Resp> refreshLoginToken() async {
    final Options options = Options(
      extra: {"$MikanFunc": MikanFunc.refreshLoginToken},
    );
    return await Http.get(
      MikanUrl.mySubscribed,
      options: options,
    );
  }

  static Future<Resp> refreshForgotPasswordToken() async {
    final Options options = Options(
      extra: {"$MikanFunc": MikanFunc.refreshForgotPasswordToken},
    );
    return await Http.get(
      MikanUrl.forgotPassword,
      options: options,
    );
  }

  static Future<Resp> refreshRegisterToken() async {
    final Options options = Options(
      extra: {"$MikanFunc": MikanFunc.refreshRegisterToken},
    );
    return await Http.get(
      MikanUrl.register,
      options: options,
    );
  }

  static Future<Resp> fonts() async {
    return await Http.get(ExtraUrl.fontsManifest);
  }

  static Future<Resp> release() async {
    return await Http.get(ExtraUrl.releaseVersion);
  }

  static Future<Resp> releaseMeta() async {
    return await Http.get(ExtraUrl.mikanReleaseMeta);
  }
}
