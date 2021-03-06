import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart' hide Intent, Action;
import 'package:flutter/services.dart';
import 'package:intent/action.dart';
import 'package:intent/flag.dart';
import 'package:intent/intent.dart';
import 'package:mikan_flutter/internal/logger.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

extension IterableExt<T> on Iterable<T> {
  bool get isNullOrEmpty => this == null || this.isEmpty;

  bool get isSafeNotEmpty => !this.isNullOrEmpty;

  T getOrNull(final int index) {
    if (this.isNullOrEmpty) return null;
    return this.elementAt(index);
  }

  bool eq(Iterable<T> other) {
    if (this == null) return other == null;
    if (other == null || this.length != other.length) return false;
    for (int index = 0; index < this.length; index += 1) {
      if (this.elementAt(index) != other.elementAt(index)) return false;
    }
    return true;
  }

  bool ne(Iterable<T> other) => !this.eq(other);
}

extension ListExt<T> on List<T> {
  bool get isNullOrEmpty => this == null || this.isEmpty;

  bool get isSafeNotEmpty => !this.isNullOrEmpty;

  T getOrNull(final int index) {
    if (this.isNullOrEmpty) return null;
    return this[index];
  }

  bool eq(List<T> other) {
    if (this == null) return other == null;
    if (other == null || this.length != other.length) return false;
    for (int index = 0; index < this.length; index += 1) {
      if (this[index] != other[index]) return false;
    }
    return true;
  }

  bool ne(List<T> other) => !this.eq(other);
}

extension MapExt<K, V> on Map<K, V> {
  bool get isNullOrEmpty => this == null || this.isEmpty;

  bool get isSafeNotEmpty => !this.isNullOrEmpty;

  V getOrNull(K key) => this == null ? null : this[key];

  bool eq(Map<K, V> other) {
    if (this == null) return other == null;
    if (other == null || this.length != other.length) return false;
    for (final K key in this.keys) {
      if (!other.containsKey(key) || other[key] != this[key]) {
        return false;
      }
    }
    return true;
  }

  bool ne(Map<K, V> other) => !this.eq(other);
}

extension StringExt on String {
  bool get isNullOrBlank => this == null || this.isEmpty;

  bool get isNotBlank => !this.isNullOrBlank;

  toast() async {
    if (this.isNotBlank) {
      showToastWidget(
        Builder(
          builder: (context) {
            final Color bgc = Theme.of(context).accentColor;
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [bgc, bgc.withOpacity(0.87)],
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.024),
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        spreadRadius: 3.0,
                      ),
                    ],
                  ),
                  child: Text(
                    this,
                    style: TextStyle(
                      color: bgc.computeLuminance() < 0.5
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  launchAppAndCopy() async {
    Future _doOtherAction() async {
      if (await canLaunch(this)) {
        await launch(this);
      } else {
        "未找到可打开应用".toast();
      }
    }

    if (this.isNullOrBlank) return "内容为空，取消操作".toast();
    await FlutterClipboard.copy(this);
    if (Platform.isAndroid) {
      Intent()
        ..setAction(Action.ACTION_VIEW)
        ..setData(Uri.parse(this))
        ..addFlag(Flag.FLAG_ACTIVITY_NEW_TASK |
            Flag.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
        ..startActivity().catchError((e) async {
          logd(e);
          await _doOtherAction();
        });
    } else {
      await _doOtherAction();
    }
  }

  copy() {
    if (this.isNullOrBlank) return "内容为空，取消操作".toast();
    FlutterClipboard.copy(this).then((_) => "成功复制到剪切板".toast());
  }

  share() {
    if (this.isNullOrBlank) return "内容为空，取消操作".toast();
    Share.share(this);
    FlutterClipboard.copy(this).then((_) => "尝试分享，并复制到剪切板".toast());
  }
}

extension RefreshControllerExt on RefreshController {
  completed([bool noMore = false]) {
    if (this.isRefresh) {
      this.refreshCompleted();
    } else if (this.isLoading) {
      if (noMore) {
        this.loadNoData();
      } else {
        this.loadComplete();
      }
    }
  }

  failed() {
    if (this.isRefresh) {
      this.refreshFailed();
    } else if (this.isLoading) {
      this.loadFailed();
    }
  }
}

/// https://stackoverflow.com/a/50081214/10064463
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

const SystemUiOverlayStyle _light = SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  statusBarColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

const SystemUiOverlayStyle _dark = SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  statusBarColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

extension BuildContextExt on BuildContext {
  SystemUiOverlayStyle get fitSystemUiOverlayStyle {
    return Theme.of(this).scaffoldBackgroundColor.computeLuminance() < 0.5
        ? _light
        : _dark;
  }
}

eee() {}
