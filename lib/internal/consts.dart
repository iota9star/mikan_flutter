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
}

class MikanUrl {
  const MikanUrl._();

  static const String BASE_URL = "https://mikanani.me";

  /// https://mikanani.me/Home/EpisodeUpdateRows?predate=0&enddate=1&maximumitems=6
  static const String DAY_URL = "/Home/EpisodeUpdateRows";

  ///  https://mikanani.me/Home/BangumiCoverFlowByDayOfWeek?year=2020&seasonStr=%E5%86%AC
  static const String WEEK_URL = "/Home/BangumiCoverFlowByDayOfWeek";

  ///  https://mikanani.me/Home/Search?searchstr=%E5%88%80%E5%89%91%E7%A5%9E%E5%9F%9F&subgroupid=19&page=1
  static const String SEARCH = "/Home/Search";

  /// https://mikanani.me/Home/Classic/1
  static const String LIST = "/Home/Classic";

  /// https://mikanani.me/Home/PublishGroup/33
  static const String SUBGROUP = "/Home/PublishGroup";

  /// https://mikanani.me/Home/Bangumi/2229
  static const String BANGUMI = "/Home/Bangumi";

  /// https://mikanani.me/Home/ExpandEpisodeTable?bangumiId=227&subtitleGroupId=161&take=65
  static const String BANGUMI_MORE = "/Home/ExpandEpisodeTable";

  /// https://mikanani.me/Account/Login?ReturnUrl=%2F
  static const String LOGIN = "/Account/Login";

  /// https://mikanani.me/Home/SubscribeBangumi
  static const String SUBSCRIBE_BANGUMI = "/Home/SubscribeBangumi";

  /// https://mikanani.me/Home/UnsubscribeBangumi
  static const String UNSUBSCRIBE_BANGUMI = "/Home/UnsubscribeBangumi";
}
