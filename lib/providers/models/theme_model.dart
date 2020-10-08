import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/base/store.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';

class ThemeModel extends BaseModel {
  static const KEY_DARK_MODE = "theme_dark_mode";
  static const KEY_PRIMARY_COLOR = "theme_primary_color";
  static const KEY_ACCENT_COLOR = "theme_accent_color";
  static const KEY_BACKGROUND_COLOR = "theme_background_color";
  static const KEY_FOREGROUND_COLOR = "theme_foreground_color";

  ColorSwatch _primaryColorSwatch;
  ColorSwatch _accentColorSwatch;
  Color _primaryColor;
  Color _accentColor;
  Color _foregroundColor;
  Color _backgroundColor;
  bool _darkMode;

  ColorSwatch get primaryColorSwatch => _primaryColorSwatch;

  ColorSwatch get accentColorSwatch => _accentColorSwatch;

  Color get primaryColor => _primaryColor;

  Color get accentColor => _accentColor;

  bool get darkMode => _darkMode;

  ThemeModel() {
    final List<ColorSwatch> primaries = Colors.primaries;
    final List<ColorSwatch> accents = Colors.accents;
    final int primary =
        Store.sp.getInt(KEY_PRIMARY_COLOR) ?? primaries[6].value;
    final int accent = Store.sp.getInt(KEY_ACCENT_COLOR) ?? accents[5].value;
    final int background = Store.sp.getInt(KEY_BACKGROUND_COLOR) ?? 0xFFDDE4F0;
    final int foreground =
        Store.sp.getInt(KEY_FOREGROUND_COLOR) ?? Colors.white.value;
    _primaryColor = Color(primary);
    _accentColor = Color(accent);
    _backgroundColor = Color(background);
    _foregroundColor = Color(foreground);
    _darkMode = Store.sp.getBool(KEY_DARK_MODE) ?? false;
    for (ColorSwatch swatch in primaries) {
      if (swatch.value == primary) {
        _primaryColorSwatch = swatch;
        break;
      }
    }
    for (ColorSwatch swatch in accents) {
      if (swatch.value == accent) {
        _accentColorSwatch = swatch;
        break;
      }
    }
  }

  themeData({bool platformDarkMode = false}) {
    var isDark = platformDarkMode || _darkMode;
    Brightness brightness = isDark ? Brightness.dark : Brightness.light;

    ThemeData themeData = ThemeData(
      brightness: brightness,
      // 主题颜色属于亮色系还是属于暗色系(eg:dark时,AppBarTitle文字及状态栏文字的颜色为白色,反之为黑色)
      // 这里设置为dark目的是,不管App是明or暗,都将appBar的字体颜色的默认值设为白色.
      // 再AnnotatedRegion<SystemUiOverlayStyle>的方式,调整响应的状态栏颜色
      primaryColorBrightness: Brightness.dark,
      accentColorBrightness: Brightness.dark,
      primarySwatch: _primaryColorSwatch,
      accentColor: _accentColorSwatch,
      fontFamily: 'zcoolxw',
//      fontFamily: 'MaShanZheng',
    );

    themeData = themeData.copyWith(
      brightness: brightness,
      accentColor: _accentColorSwatch,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: _primaryColorSwatch,
        brightness: brightness,
      ),
      backgroundColor: _backgroundColor,
      appBarTheme: themeData.appBarTheme.copyWith(elevation: 0),
      splashColor: Colors.grey.withOpacity(0.5),
      hintColor: themeData.hintColor.withAlpha(90),
      errorColor: Colors.red,
      cursorColor: _accentColorSwatch,
    );
    return themeData;
  }

  void syncTheme(
      {bool darkMode, MaterialColor primaryColor, MaterialColor accentColor}) {
    _darkMode = darkMode ?? _darkMode;
    _primaryColorSwatch = primaryColor ?? _primaryColorSwatch;
    _accentColorSwatch = accentColor ?? _accentColorSwatch;
    notifyListeners();
    _sync2Store(_darkMode, _primaryColorSwatch, _accentColorSwatch);
  }

  void _sync2Store(bool darkMode, MaterialColor primaryColor,
      MaterialColor accentColor) async {
    await Future.wait([
      Store.sp.setBool(KEY_DARK_MODE, darkMode),
      Store.sp.setInt(KEY_PRIMARY_COLOR, primaryColor.value),
      Store.sp.setInt(KEY_ACCENT_COLOR, accentColor.value),
    ]);
  }
}
