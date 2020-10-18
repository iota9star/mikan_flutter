import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

extension IterableExt<T> on Iterable<T> {
  bool get isNullOrEmpty => this == null || this.isEmpty;

  bool get isNotEmpty => !this.isNullOrEmpty;

  T getOrNull(final int index) {
    if (this.isNullOrEmpty) return null;
    return this.elementAt(index);
  }
}

extension MapExt<K, V> on Map<K, V> {
  bool get isNullOrEmpty => this == null || this.isEmpty;

  bool get isNotEmpty => !this.isNullOrEmpty;

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
