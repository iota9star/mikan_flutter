import 'package:dio/dio.dart';
import 'package:mikan_flutter/internal/consts.dart';
import 'package:mikan_flutter/internal/http.dart';

class Repo {
  const Repo._();

  static Future<Resp> season(final String year, final String season) async {
    final parameters = {"year": year, "seasonStr": season};
    final extra = {"$MikanFunc": MikanFunc.SEASON};
    final Options options = Options(extra: extra);
    return await Http.get(
      MikanUrl.SEASON_UPDATE,
      queryParameters: parameters,
      options: options,
    );
  }

  static Future<Resp> day(final int pre, final int end) async {
    final parameters = {"predate": pre, "enddate": end, "maximumitems": 6};
    final extra = {"$MikanFunc": MikanFunc.DAY};
    final Options options = Options(extra: extra);
    return await Http.get(
      MikanUrl.DAY_UPDATE,
      queryParameters: parameters,
      options: options,
    );
  }

  static Future<Resp> ova() async {
    return await day(-1, -1);
  }

  static Future<Resp> search(
    final String keywords, {
    final String subgroupId,
  }) async {
    final parameters = {"searchstr": keywords, "subgroupid": subgroupId};
    final extra = {"$MikanFunc": MikanFunc.SEARCH};
    final Options options = Options(extra: extra);
    return await Http.get(
      MikanUrl.SEARCH,
      queryParameters: parameters,
      options: options,
    );
  }

  static Future<Resp> list(final int page) async {
    final extra = {"$MikanFunc": MikanFunc.LIST};
    final Options options = Options(extra: extra);
    return await Http.get("${MikanUrl.LIST}/${page ?? ""}", options: options);
  }

  static Future<Resp> index() async {
    final extra = {"$MikanFunc": MikanFunc.INDEX};
    final Options options = Options(extra: extra);
    return await Http.get(MikanUrl.BASE_URL, options: options);
  }

  static Future<Resp> subgroup(final String subgroupId) async {
    final extra = {"$MikanFunc": MikanFunc.SUBGROUP};
    final Options options = Options(extra: extra);
    return await Http.get("${MikanUrl.SUBGROUP}/$subgroupId", options: options);
  }

  static Future<Resp> bangumi(final String id) async {
    final extra = {"$MikanFunc": MikanFunc.BANGUMI};
    final Options options = Options(extra: extra);
    return await Http.get("${MikanUrl.BANGUMI}/$id", options: options);
  }

  static Future<Resp> bangumiMore(
    final String bangumiId,
    final String subgroupId,
    final int take,
  ) async {
    final extra = {"$MikanFunc": MikanFunc.BANGUMI_MORE};
    final Options options = Options(extra: extra);
    return await Http.get(
      "${MikanUrl.BANGUMI_MORE}",
      queryParameters: {
        "bangumiId": bangumiId,
        "subtitleGroupId": subgroupId,
        "take": take,
      },
      options: options,
    );
  }

  static Future<Resp> details(final String url) async {
    final extra = {"$MikanFunc": MikanFunc.DETAILS};
    final Options options = Options(extra: extra);
    return await Http.get(url, options: options);
  }

  static Future<Resp> subscribeBangumi(
    final String bangumiId,
    final bool subscribe, {
    final String subgroupId,
  }) async {
    final Options options = Options(
      headers: {
        "origin": "https://mikanani.me",
        "referer": "https://mikanani.me/",
        "cache-control": "no-cache",
        "x-requested-with": "XMLHttpRequest",
      },
      contentType: "application/json; charset=UTF-8",
      responseType: ResponseType.json,
    );
    return await Http.postJSON(
      subscribe ? MikanUrl.UNSUBSCRIBE_BANGUMI : MikanUrl.SUBSCRIBE_BANGUMI,
      data: <String, dynamic>{
        "BangumiID": bangumiId,
        "SubtitleGroupID": subgroupId,
      },
      options: options,
    );
  }

  static Future<Resp> mySubscribedSeasonBangumi(
      final String year, final String season) async {
    final Options options = Options(headers: {
      "referer": "https://mikanani.me/Home/MyBangumi",
    }, extra: {
      "$MikanFunc": MikanFunc.SUBSCRIBED_SEASON
    });
    return await Http.get(
      MikanUrl.SUBSCRIBED_SEASON,
      queryParameters: <String, dynamic>{
        "year": year,
        "seasonStr": season,
      },
      options: options,
    );
  }

  static Future<Resp> submit(final Map<String, dynamic> loginParams) async {
    final Options options = Options(
      headers: {
        "origin": "https://mikanani.me",
        "referer": "https://mikanani.me/",
        "cache-control": "no-cache",
      },
      contentType: "application/x-www-form-urlencoded",
    );
    return await Http.postForm(
      MikanUrl.LOGIN,
      queryParameters: {"ReturnUrl": "/"},
      data: loginParams,
      options: options,
    );
  }
}
