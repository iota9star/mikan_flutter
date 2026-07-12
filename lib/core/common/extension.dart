import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:riverpod/riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:mikan/core/common/launcher.dart';

Future<void> _copyToClipboard(String text) {
  return Clipboard.setData(ClipboardData(text: text));
}

/// Extension for checking if a nullable collection (Map or Iterable) is null or empty.
extension NullableMapExt<K, V> on Map<K, V>? {
  /// Returns `true` if this map is `null` or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

/// Extension for checking if a nullable iterable is null or empty.
extension NullableIterableExt<T> on Iterable<T>? {
  /// Returns `true` if this iterable is `null` or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

extension NullableStringExt on String? {
  bool get isNullOrBlank => this == null || this!.isBlank;

  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotBlank => this != null && !this!.isBlank;

  void toast() {
    if (isNullOrBlank) {
      return;
    }
    SmartDialog.showToast(this!, alignment: const Alignment(0.0, 0.72));
    HapticFeedback.mediumImpact();
  }

  Future<void> launchAppAndCopy() => LauncherHelper.copyAndLaunch(this ?? '');

  void copy() {
    if (isNullOrBlank) {
      return '内容为空，取消操作'.toast();
    }
    _copyToClipboard(this!).then((_) => '已复制到剪切板'.toast());
  }

  void share() {
    if (isNullOrBlank) {
      return '内容为空，取消操作'.toast();
    }
    SharePlus.instance.share(ShareParams(text: this));
    _copyToClipboard(this!).then((_) => '尝试分享，并复制到剪切板'.toast());
  }
}

extension StringExt on String {
  bool get isBlank {
    if (length == 0) {
      return true;
    }
    for (final int value in runes) {
      if (!_isWhitespace(value)) {
        return false;
      }
    }
    return true;
  }

  bool _isWhitespace(int rune) =>
      (rune >= 0x0009 && rune <= 0x000D) ||
      rune == 0x0020 ||
      rune == 0x0085 ||
      rune == 0x00A0 ||
      rune == 0x1680 ||
      rune == 0x180E ||
      (rune >= 0x2000 && rune <= 0x200A) ||
      rune == 0x2028 ||
      rune == 0x2029 ||
      rune == 0x202F ||
      rune == 0x205F ||
      rune == 0x3000 ||
      rune == 0xFEFF;
}

const SystemUiOverlayStyle lightSystemUiOverlayStyle = SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  statusBarColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

const SystemUiOverlayStyle darkSystemUiOverlayStyle = SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  statusBarColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.dark,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

extension BuildContextExt on BuildContext {
  SystemUiOverlayStyle get fitSystemUiOverlayStyle {
    return Theme.of(this).colorScheme.surface.isDark ? lightSystemUiOverlayStyle : darkSystemUiOverlayStyle;
  }

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colors => theme.colorScheme;
}

extension BrightnessColor on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}

extension ColorExt on Color {
  bool get isDark {
    return computeLuminance() < 0.5;
  }
}

extension ThemeDataExt on ThemeData {
  Color get primary => colorScheme.primary;

  Color get secondary => colorScheme.secondary;
}

extension AnyNotifierExt<S, T> on AnyNotifier<S, T> {
  /// Sets the state only if the ref is still mounted.
  void setIfMounted(Ref ref, S value) {
    if (ref.mounted) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      state = value;
    }
  }

  /// Updates the state only if the ref is still mounted.
  void updateIfMounted(Ref ref, S Function(S) updater) {
    if (ref.mounted) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      state = updater(state);
    }
  }
}
