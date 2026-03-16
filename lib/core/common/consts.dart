const APP_CHANNEL = String.fromEnvironment('APP_CHANNEL', defaultValue: 'github');

class MikanUrls {
  const MikanUrls._();

  static const List<String> baseUrls = ['https://mikanime.tv', 'https://mikanani.me'];

  static String get defaultBaseUrl => baseUrls.last;

  static String baseUrl = defaultBaseUrl;

  static bool setBaseUrl(String url) {
    if (baseUrls.contains(url)) {
      baseUrl = url;
      return true;
    }
    return false;
  }

  static String get currentBaseUrl => baseUrl;

  static String get dayUpdate => '$baseUrl/Home/EpisodeUpdateRows';

  static String get seasonUpdate => '$baseUrl/Home/BangumiCoverFlowByDayOfWeek';

  static String get search => '$baseUrl/Home/Search';

  static String get list => '$baseUrl/Home/Classic';

  static String get subgroup => '$baseUrl/Home/PublishGroup';

  static String get bangumi => '$baseUrl/Home/Bangumi';

  static String get bangumiMore => '$baseUrl/Home/ExpandEpisodeTable';

  static String get login => '$baseUrl/Account/Login';

  static String get register => '$baseUrl/Account/Register';

  static String get forgotPassword => '$baseUrl/Account/ForgotPassword';

  static String get subscribeBangumi => '$baseUrl/Home/SubscribeBangumi';

  static String get unsubscribeBangumi => '$baseUrl/Home/UnsubscribeBangumi';

  static String get subscribedSeason => '$baseUrl/Home/BangumiCoverFlow';

  static String get mySubscribed => '$baseUrl/Home/MyBangumi';
}

class ExtraUrl {
  const ExtraUrl._();

  static const String fontsBaseUrl = 'https://fonts.bytex.space';
  static const String fontsManifest = '$fontsBaseUrl/fonts-manifest.json';
  static const String releaseVersion = 'https://api.github.com/repos/iota9star/mikan_flutter/releases/latest';
}
