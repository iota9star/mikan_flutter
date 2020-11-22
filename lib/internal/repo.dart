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
    final bool subscribe,
    final String bangumiId, {
    final String subgroupId,
  }) async {
    final Options options = Options(
      headers: {
        "origin": "https://mikanani.me",
        "referer": "https://mikanani.me/",
      },
      contentType: "application/json; charset=UTF-8",
      responseType: ResponseType.json,
    );
    return await Http.post(
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
        "dnt": "1",
        "pragma": "no-cache",
        "sec-ch-ua":
            '"Chromium";v="86", "\"Not\\A;Brand";v="99", "Google Chrome";v="86"',
        "sec-ch-ua-mobile": "?0",
        "sec-fetch-dest": "document",
        "sec-fetch-mode": "navigate",
        "sec-fetch-site": "same-origin",
        "sec-fetch-user": "?1",
        "accept":
            "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
        "accept-encoding": "gzip, deflate, br",
        "accept-language": "zh-CN,zh;q=0.9,ja;q=0.8"
      },
      contentType: "application/x-www-form-urlencoded",
    );
    return await Http.post(
      MikanUrl.LOGIN,
      queryParameters: {"ReturnUrl": "/"},
      data: loginParams,
      options: options,
    );
  }
}
