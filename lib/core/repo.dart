import 'package:dio/dio.dart';
import 'package:mikan_flutter/core/consts.dart';
import 'package:mikan_flutter/core/http.dart';

class Repo {
  const Repo._();

  static Future<Resp> season(final String year, final String season) async {
    final parameters = {"year": year, "seasonStr": season};
    final extra = {"$MikanFunc": MikanFunc.SEASON};
    final Options options = Options(extra: extra);
    return await Http.get(
      MikanUrl.WEEK_URL,
      queryParameters: parameters,
      options: options,
    );
  }

  static Future<Resp> day(final int pre, final int end) async {
    final parameters = {"predate": pre, "enddate": end, "maximumitems": 6};
    final extra = {"$MikanFunc": MikanFunc.DAY};
    final Options options = Options(extra: extra);
    return await Http.get(
      MikanUrl.DAY_URL,
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

  static Future<Resp> details(final String url) async {
    final extra = {"$MikanFunc": MikanFunc.DETAILS};
    final Options options = Options(extra: extra);
    return await Http.get(url, options: options);
  }

  static submit(final Map<String, dynamic> loginParams) async {
    final Options options = Options(
      headers: {
        "origin": "https://mikanani.me",
        "referer": "https://mikanani.me/",
      },
      contentType: "application/x-www-form-urlencoded",
    );
    return await Http.post(
      MikanUrl.LOGIN,
      data: loginParams,
      options: options,
    );
  }
}
