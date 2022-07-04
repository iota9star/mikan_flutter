import 'dart:io';

class MikanFunc {
  const MikanFunc._();

  static const String season = "SEASON";
  static const String day = "DAY";
  static const String search = "SEARCH";
  static const String list = "LIST";
  static const String user = "USER";
  static const String index = "INDEX";
  static const String subgroup = "SUBGROUP";
  static const String bangumi = "BANGUMI";
  static const String bangumiMore = "BANGUMI_MORE";
  static const String details = "DETAILS";
  static const String subscribeBangumi = "SUBSCRIBE_BANGUMI";
  static const String unsubscribeBangumi = "UNSUBSCRIBE_BANGUMI";
  static const String subscribedSeason = "SUBSCRIBED_SEASON";
  static const String refreshLoginToken = "REFRESH_LOGIN_TOKEN";
  static const String refreshRegisterToken = "REFRESH_REGISTER_TOKEN";
  static const String refreshForgotPasswordToken =
      "REFRESH_FORGOTPASSWORD_TOKEN";
}

class MikanUrl {
  const MikanUrl._();

  static const String baseUrl = "https://mikanani.me";

  /// [最近更新](https://mikanani.me/Home/EpisodeUpdateRows?predate=0&enddate=1&maximumitems=6)
  static const String dayUpdate = "/Home/EpisodeUpdateRows";

  /// [季度信息](https://mikanani.me/Home/BangumiCoverFlowByDayOfWeek?year=2020&seasonStr=%E5%86%AC)
  static const String seasonUpdate = "/Home/BangumiCoverFlowByDayOfWeek";

  /// [搜索](https://mikanani.me/Home/Search?searchstr=%E5%88%80%E5%89%91%E7%A5%9E%E5%9F%9F&subgroupid=19&page=1)
  static const String search = "/Home/Search";

  /// [更新列表](https://mikanani.me/Home/Classic/1)
  static const String list = "/Home/Classic";

  /// [字幕组信息](https://mikanani.me/Home/PublishGroup/33)
  static const String subgroup = "/Home/PublishGroup";

  /// [番组信息](https://mikanani.me/Home/Bangumi/2229)
  static const String bangumi = "/Home/Bangumi";

  /// [番组BT列表](https://mikanani.me/Home/ExpandEpisodeTable?bangumiId=227&subtitleGroupId=161&take=65)
  static const String bangumiMore = "/Home/ExpandEpisodeTable";

  /// [登录](https://mikanani.me/Account/Login?ReturnUrl=%2F)
  static const String login = "/Account/Login";

  /// [注册](https://mikanani.me/Account/Register)
  static const String register = "/Account/Register";

  ///[忘记密码](https://mikanani.me/Account/ForgotPassword)
  static const String forgotPassword = "/Account/ForgotPassword";

  /// [订阅](https://mikanani.me/Home/SubscribeBangumi)
  static const String subscribeBangumi = "/Home/SubscribeBangumi";

  /// [取消订阅](https://mikanani.me/Home/UnsubscribeBangumi)
  static const String unsubscribeBangumi = "/Home/UnsubscribeBangumi";

  /// [季度订阅](https://mikanani.me/Home/BangumiCoverFlow?year=2020&seasonStr=%E7%A7%8B)
  static const String subscribedSeason = "/Home/BangumiCoverFlow";

  /// [我的订阅页 用于刷新token](https://mikanani.me/Home/MyBangumi)
  static const String mySubscribed = "/Home/MyBangumi";
}

class ExtraUrl {
  const ExtraUrl._();

  static const String fontsBaseUrl =
      "https://raw.githubusercontent.com/iota9star/fonts/master";
  static const String fontsManifest = "$fontsBaseUrl/manifest.json";
  static const String releaseVersion =
      "https://api.github.com/repos/iota9star/mikan_flutter/releases/latest";
}

final isMobile = Platform.isIOS || Platform.isAndroid;
final isSupportFirebase = isMobile || Platform.isMacOS;
