const APP_CHANNEL =
    String.fromEnvironment('APP_CHANNEL', defaultValue: 'github');

class MikanFunc {
  const MikanFunc._();

  static const String season = 'SEASON';
  static const String day = 'DAY';
  static const String search = 'SEARCH';
  static const String list = 'LIST';
  static const String user = 'USER';
  static const String index = 'INDEX';
  static const String subgroup = 'SUBGROUP';
  static const String bangumi = 'BANGUMI';
  static const String bangumiMore = 'BANGUMI_MORE';
  static const String details = 'DETAILS';
  static const String subscribeBangumi = 'SUBSCRIBE_BANGUMI';
  static const String unsubscribeBangumi = 'UNSUBSCRIBE_BANGUMI';
  static const String subscribedSeason = 'SUBSCRIBED_SEASON';
  static const String refreshLoginToken = 'REFRESH_LOGIN_TOKEN';
  static const String refreshRegisterToken = 'REFRESH_REGISTER_TOKEN';
  static const String refreshForgotPasswordToken =
      'REFRESH_FORGOTPASSWORD_TOKEN';
}

class MikanUrls {
  const MikanUrls._();

  static const List<String> baseUrls = [
    'https://mikanime.tv',
    'https://mikanani.me',
  ];

  static late String baseUrl;

  /// [最近更新](https://mikanani.me/Home/EpisodeUpdateRows?predate=0&enddate=1&maximumitems=6)
  static String get dayUpdate => '$baseUrl/Home/EpisodeUpdateRows';

  /// [季度信息](https://mikanani.me/Home/BangumiCoverFlowByDayOfWeek?year=2020&seasonStr=%E5%86%AC)
  static String get seasonUpdate => '$baseUrl/Home/BangumiCoverFlowByDayOfWeek';

  /// [搜索](https://mikanani.me/Home/Search?searchstr=%E5%88%80%E5%89%91%E7%A5%9E%E5%9F%9F&subgroupid=19&page=1)
  static String get search => '$baseUrl/Home/Search';

  /// [更新列表](https://mikanani.me/Home/Classic/1)
  static String get list => '$baseUrl/Home/Classic';

  /// [字幕组信息](https://mikanani.me/Home/PublishGroup/33)
  static String get subgroup => '$baseUrl/Home/PublishGroup';

  /// [番组信息](https://mikanani.me/Home/Bangumi/2229)
  static String get bangumi => '$baseUrl/Home/Bangumi';

  /// [番组BT列表](https://mikanani.me/Home/ExpandEpisodeTable?bangumiId=227&subtitleGroupId=161&take=65)
  static String get bangumiMore => '$baseUrl/Home/ExpandEpisodeTable';

  /// [登录](https://mikanani.me/Account/Login?ReturnUrl=%2F)
  static String get login => '$baseUrl/Account/Login';

  /// [注册](https://mikanani.me/Account/Register)
  static String get register => '$baseUrl/Account/Register';

  ///[忘记密码](https://mikanani.me/Account/ForgotPassword)
  static String get forgotPassword => '$baseUrl/Account/ForgotPassword';

  /// [订阅](https://mikanani.me/Home/SubscribeBangumi)
  static String get subscribeBangumi => '$baseUrl/Home/SubscribeBangumi';

  /// [取消订阅](https://mikanani.me/Home/UnsubscribeBangumi)
  static String get unsubscribeBangumi => '$baseUrl/Home/UnsubscribeBangumi';

  /// [季度订阅](https://mikanani.me/Home/BangumiCoverFlow?year=2020&seasonStr=%E7%A7%8B)
  static String get subscribedSeason => '$baseUrl/Home/BangumiCoverFlow';

  /// [我的订阅页 用于刷新token](https://mikanani.me/Home/MyBangumi)
  static String get mySubscribed => '$baseUrl/Home/MyBangumi';
}

class ExtraUrl {
  const ExtraUrl._();

  static const String fontsBaseUrl = 'https://fonts.bytex.space';
  static const String fontsManifest = '$fontsBaseUrl/fonts-manifest.json';
  static const String releaseVersion =
      'https://api.github.com/repos/iota9star/mikan_flutter/releases/latest';
}
