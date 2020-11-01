import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
