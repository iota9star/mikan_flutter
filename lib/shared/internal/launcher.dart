import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:clipboard/clipboard.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'extension.dart';

class LauncherHelper {
  LauncherHelper._();

  static Future<void> copyAndLaunch(String url, {LaunchMode fallbackMode = LaunchMode.externalApplication}) async {
    if (url.isBlank) {
      return '内容为空，取消操作'.toast();
    }

    await FlutterClipboard.copy(url);

    if (Platform.isAndroid) {
      unawaited(
        AndroidIntent(
          action: 'android.intent.action.VIEW',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED],
          data: url,
        ).launch().catchError((Object e, StackTrace stackTrace) {
          return _launchUrlFallback(url, fallbackMode);
        }),
      );
    } else {
      await _launchUrlFallback(url, fallbackMode);
    }
  }

  static Future<void> _launchUrlFallback(String url, LaunchMode mode) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: mode);
    } else {
      '未找到可打开应用'.toast();
    }
  }
}
