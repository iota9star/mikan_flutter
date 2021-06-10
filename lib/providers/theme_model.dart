import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Theme;
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/model/theme_item.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:mikan_flutter/topvars.dart';

class ThemeModel extends BaseModel {
  late ThemeItem _themeItem;

  ThemeItem get themeItem => _themeItem;

  set themeItem(ThemeItem value) {
    this._themeItem = value;
    MyHive.db.put(HiveDBKey.THEME_ID, this._themeItem.id);
    notifyListeners();
  }

  ThemeModel() {
    _themeItem = MyHive.themeItemBox.values.firstWhere((element) =>
        element.id == MyHive.db.get(HiveDBKey.THEME_ID, defaultValue: 1));
  }

  theme({bool darkTheme = false}) {
    final bool isDark = _themeItem.autoMode ? darkTheme : _themeItem.isDark;
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
    final backgroundColor = Color(
      isDark ? _themeItem.darkBackgroundColor : _themeItem.lightBackgroundColor,
    );
    final fontFamily = _themeItem.fontFamily;
    final underlineInputBorder = UnderlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: borderRadius16,
    );
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
      splashColor: accentColor.withOpacity(0.27),
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryColor,
              primaryVariant: primaryColor.darken(0.24),
              secondary: accentColor,
              secondaryVariant: accentColor.darken(0.36),
              background: backgroundColor,
              surface: backgroundColor,
            )
          : ColorScheme.light(
              primary: primaryColor,
              primaryVariant: primaryColor.darken(0.2),
              secondary: accentColor,
              secondaryVariant: accentColor.darken(0.36),
              background: backgroundColor,
              surface: backgroundColor,
            ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        focusedBorder: underlineInputBorder,
        disabledBorder: underlineInputBorder,
        enabledBorder: underlineInputBorder,
        errorBorder: underlineInputBorder,
        focusedErrorBorder: underlineInputBorder,
        border: underlineInputBorder,
        prefixStyle: TextStyle(color: accentColor),
        suffixStyle: TextStyle(color: accentColor),
        focusColor: accentColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.0),
        hintStyle: TextStyle(height: 1.4, color: accentColor),
        labelStyle: TextStyle(fontSize: 16.0, color: accentColor),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accentColor,
        selectionColor: accentColor,
        selectionHandleColor: accentColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: accentColor,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius16),
          minimumSize: const Size(0, 48.0),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: backgroundColor,
        shape: const RoundedRectangleBorder(),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(color: primaryColor),
          minimumSize: const Size(0, 48.0),
        ),
      ),
    );
    return themeData;
  }
}
