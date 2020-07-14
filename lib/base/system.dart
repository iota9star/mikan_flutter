import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

class System {
  static Future<PackageInfo> getAppPackageInfo() async =>
      await PackageInfo.fromPlatform();

  static Future<String> getAppVersion() async =>
      (await PackageInfo.fromPlatform()).version;

  static Future<String> getBuildNum() async =>
      (await PackageInfo.fromPlatform()).buildNumber;

  /// 获取设备信息
  static Future getDeviceModel() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.model;
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return info.model;
    } else {
      return null;
    }
  }

  /// 获取应用的缓存路径
  static Future getAppCachePath() async => (await getTemporaryDirectory()).path;

  /// 获取应用的内置文件路径
  static Future getAppDocPath() async =>
      (await getApplicationDocumentsDirectory()).path;
}
