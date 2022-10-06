import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Theme;
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/model/fonts.dart';
import 'package:mikan_flutter/model/theme_item.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:mikan_flutter/topvars.dart';

class ThemeModel extends BaseModel {
  late ThemeItem _themeItem;

  ThemeItem get themeItem => _themeItem;

  set themeItem(ThemeItem value) {
    _themeItem = value;
    MyHive.db.put(HiveDBKey.themeId, _themeItem.id);
    notifyListeners();
  }

  ThemeModel() {
    _themeItem = MyHive.themeItemBox.values.firstWhere((element) =>
        element.id == MyHive.db.get(HiveDBKey.themeId, defaultValue: 1));
    if (_themeItem.fontFamily.isNullOrBlank) {
      _themeItem.fontFamily = defaultFontFamilyName;
    }
  }

  theme({bool darkTheme = false}) {
    final bool isDark = _themeItem.autoMode ? darkTheme : _themeItem.isDark;
    final Brightness brightness = isDark ? Brightness.dark : Brightness.light;
    final primaryColor = Color(_themeItem.primaryColor);
    final accentColor = Color(_themeItem.accentColor);
    final scaffoldBackgroundColor = Color(
      isDark
          ? _themeItem.darkScaffoldBackgroundColor
          : _themeItem.lightScaffoldBackgroundColor,
    );
    final backgroundColor = Color(
      isDark ? _themeItem.darkBackgroundColor : _themeItem.lightBackgroundColor,
    );
    final fontFamily = _themeItem.fontFamily;
    const underlineInputBorder = UnderlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: borderRadius16,
    );
    final themeData = ThemeData(
      platform: TargetPlatform.iOS,
      brightness: brightness,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        brightness: brightness,
      ),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      fontFamily: fontFamily,
      backgroundColor: backgroundColor,
      splashColor: accentColor.withOpacity(0.27),
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryColor,
              secondary: accentColor,
              background: backgroundColor,
              surface: backgroundColor,
            )
          : ColorScheme.light(
              primary: primaryColor,
              secondary: accentColor,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14.0),
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
          shape: const RoundedRectangleBorder(borderRadius: borderRadius10),
          minimumSize: const Size(0, 40.0),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: backgroundColor,
        shape: const RoundedRectangleBorder(),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(color: primaryColor),
          minimumSize: const Size(0, 40.0),
          shape: const RoundedRectangleBorder(borderRadius: borderRadius10),
        ),
      ),
      visualDensity: VisualDensity.standard,
    );
    return themeData;
  }

  void applyFont(Font? font) {
    _themeItem.fontFamilyName = font?.name ?? defaultFontFamilyName;
    if (_themeItem.fontFamily != font?.id) {
      _themeItem.fontFamily = font?.id;
      _themeItem.save();
      themeItem = _themeItem;
    }
  }

  // 如果是 linux 系统，默认使用鸿蒙字体
  String? get defaultFontFamilyName => Platform.isLinux ? "hmsans" : null;
}
