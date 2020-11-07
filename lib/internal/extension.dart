import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

extension IterableExt<T> on Iterable<T> {
  bool get isNullOrEmpty => this == null || this.isEmpty;

  bool get isSafeNotEmpty => !this.isNullOrEmpty;

  T getOrNull(final int index) {
    if (this.isNullOrEmpty) return null;
    return this.elementAt(index);
  }
}

extension MapExt<K, V> on Map<K, V> {
  bool get isNullOrEmpty => this == null || this.isEmpty;

  bool get isSafeNotEmpty => !this.isNullOrEmpty;

  V getOrNull(K key) => this == null ? null : this[key];
}

extension StringExt on String {
  bool get isNullOrBlank => this == null || this.isEmpty;

  bool get isNotBlank => !this.isNullOrBlank;

  toast() async {
    if (this.isNotBlank) {
      showToast(this);
    }
  }

  launchApp() async {
    if (this.isNullOrBlank) return "当前地址为空，忽略".toast();
    if (await canLaunch(this)) {
      await launch(this);
    } else {
      "无法找到可打开应用".toast();
    }
  }

  copy() {
    if (this.isNullOrBlank) return "当前值为空，无内容可以复制".toast();
    FlutterClipboard.copy(this).then((_) => "复制成功".toast());
  }

  share() {
    if (this.isNullOrBlank) return "没有内容供分享".toast();
    Share.share(this);
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
