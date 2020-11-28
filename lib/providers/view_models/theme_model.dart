import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Theme;
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/model/theme_item.dart';
import 'package:mikan_flutter/providers/view_models/base_model.dart';

class ThemeModel extends BaseModel {
  ThemeItem _themeItem;

  ThemeItem get themeItem => _themeItem;

  set themeItem(ThemeItem value) {
    _themeItem = value;
    notifyListeners();
  }

  ThemeModel() {
    _themeItem = MyHive.themeItemBox.values.firstWhere(
      (element) =>
          element.id == MyHive.db.get(HiveDBKey.THEME_ID, defaultValue: 1),
      orElse: () => null,
    );
  }

  theme({bool darkTheme = false}) {
    final bool isDark = _themeItem.autoMode ? darkTheme : false;
    final Brightness brightness = isDark ? Brightness.dark : Brightness.light;
    final primaryColor = Color(_themeItem.primaryColor);
    final primaryColorBrightness = primaryColor.computeLuminance() < 0.5
        ? Brightness.dark
        : Brightness.light;
    final accentColor = Color(_themeItem.accentColor);
    final accentColorBrightness = accentColor.computeLuminance() < 0.5
        ? Brightness.dark
        : Brightness.light;
    final scaffoldBackgroundColor = Color(
      isDark
          ? _themeItem.darkScaffoldBackgroundColor
          : _themeItem.lightScaffoldBackgroundColor,
    );
    final backgroundColor = Color(isDark
        ? _themeItem.darkBackgroundColor
        : _themeItem.lightBackgroundColor);
    final fontFamily = _themeItem.fontFamily;
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
