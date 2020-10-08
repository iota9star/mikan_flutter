import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Theme;
import 'package:mikan_flutter/base/store.dart';
import 'package:mikan_flutter/model/theme.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';

class ThemeModel extends BaseModel {
  Theme _theme;

  ThemeModel() {
    _theme = Store.themeBox.values.firstWhere(
        (element) =>
            element.id == Store.themeConfig.get("theme_id", defaultValue: 1),
        orElse: () => null);
  }

  theme({bool darkTheme = false}) {
    final bool isDark = _theme.autoMode ? darkTheme : false;
    final Brightness brightness = isDark ? Brightness.dark : Brightness.light;
    final primaryColor = Color(_theme.primaryColor);
    final primaryColorBrightness = primaryColor.computeLuminance() < 0.5
        ? Brightness.dark
        : Brightness.light;
    final accentColor = Color(_theme.accentColor);
    final accentColorBrightness = accentColor.computeLuminance() < 0.5
        ? Brightness.dark
        : Brightness.light;
    final scaffoldBackgroundColor = Color(isDark
        ? _theme.darkScaffoldBackgroundColor
        : _theme.lightScaffoldBackgroundColor);
    final backgroundColor = Color(
        isDark ? _theme.darkBackgroundColor : _theme.lightBackgroundColor);
    final fontFamily = _theme.fontFamily;
    ThemeData themeData = ThemeData(
      brightness: brightness,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        brightness: brightness,
      ),
      primaryColorBrightness: primaryColorBrightness,
      accentColorBrightness: accentColorBrightness,
      primaryColor: primaryColor,
      accentColor: accentColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      fontFamily: fontFamily,
      backgroundColor: backgroundColor,
    );
    return themeData;
  }
}
