class MikanFunc {
  const MikanFunc._();

  static const String SEASON = "SEASON";
  static const String DAY = "DAY";
  static const String SEARCH = "SEARCH";
  static const String LIST = "LIST";
  static const String USER = "USER";
  static const String INDEX = "INDEX";
  static const String SUBGROUP = "SUBGROUP";
  static const String BANGUMI = "BANGUMI";
  static const String BANGUMI_MORE = "BANGUMI_MORE";
  static const String DETAILS = "DETAILS";
  static const String SUBSCRIBE_BANGUMI = "SUBSCRIBE_BANGUMI";
  static const String UNSUBSCRIBE_BANGUMI = "UNSUBSCRIBE_BANGUMI";
  static const String SUBSCRIBED_SEASON = "SUBSCRIBED_SEASON";
  static const String REFRESH_LOGIN_TOKEN = "REFRESH_LOGIN_TOKEN";
  static const String REFRESH_REGISTER_TOKEN = "REFRESH_REGISTER_TOKEN";
}

class MikanUrl {
  const MikanUrl._();

  static const String BASE_URL = "https://mikanani.me";

  /// [最近更新](https://mikanani.me/Home/EpisodeUpdateRows?predate=0&enddate=1&maximumitems=6)
  static const String DAY_UPDATE = "/Home/EpisodeUpdateRows";

  /// [季度信息](https://mikanani.me/Home/BangumiCoverFlowByDayOfWeek?year=2020&seasonStr=%E5%86%AC)
  static const String SEASON_UPDATE = "/Home/BangumiCoverFlowByDayOfWeek";

  /// [搜索](https://mikanani.me/Home/Search?searchstr=%E5%88%80%E5%89%91%E7%A5%9E%E5%9F%9F&subgroupid=19&page=1)
  static const String SEARCH = "/Home/Search";

  /// [更新列表](https://mikanani.me/Home/Classic/1)
  static const String LIST = "/Home/Classic";

  /// [字幕组信息](https://mikanani.me/Home/PublishGroup/33)
  static const String SUBGROUP = "/Home/PublishGroup";

  /// [番组信息](https://mikanani.me/Home/Bangumi/2229)
  static const String BANGUMI = "/Home/Bangumi";

  /// [番组BT列表](https://mikanani.me/Home/ExpandEpisodeTable?bangumiId=227&subtitleGroupId=161&take=65)
  static const String BANGUMI_MORE = "/Home/ExpandEpisodeTable";

  /// [登录](https://mikanani.me/Account/Login?ReturnUrl=%2F)
  static const String LOGIN = "/Account/Login";

  /// [注册](https://mikanani.me/Account/Register)
  static const String REGISTER = "/Account/Register";

  /// [订阅](https://mikanani.me/Home/SubscribeBangumi)
  static const String SUBSCRIBE_BANGUMI = "/Home/SubscribeBangumi";

  /// [取消订阅](https://mikanani.me/Home/UnsubscribeBangumi)
  static const String UNSUBSCRIBE_BANGUMI = "/Home/UnsubscribeBangumi";

  /// [季度订阅](https://mikanani.me/Home/BangumiCoverFlow?year=2020&seasonStr=%E7%A7%8B)
  static const String SUBSCRIBED_SEASON = "/Home/BangumiCoverFlow";

  /// [我的订阅页 用于刷新token](https://mikanani.me/Home/MyBangumi)
  static const String MY_SUBSCRIBED = "/Home/MyBangumi";
}
