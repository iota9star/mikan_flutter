import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'log.dart';

Future<ColorSchemePair?> getDynamicColorScheme() async {
  final corePalette =
      await DynamicColorPlugin.getCorePalette().catchError((Object? e, s) {
    e.$error(stackTrace: s);
    return null;
  });
  if (corePalette != null) {
    return ColorSchemePair(
      light: corePalette.toColorScheme(),
      dark: corePalette.toColorScheme(brightness: Brightness.dark),
    );
  }
  final accentColor =
      await DynamicColorPlugin.getAccentColor().catchError((Object? e, s) {
    e.$error(stackTrace: s);
    return null;
  });
  return accentColor != null
      ? ColorSchemePair(
          light: ColorScheme.fromSeed(seedColor: accentColor),
          dark: ColorScheme.fromSeed(
            seedColor: accentColor,
            brightness: Brightness.dark,
          ),
        )
      : null;
}

class ColorSchemePair {
  ColorSchemePair({
    required this.dark,
    required this.light,
  });

  final ColorScheme dark;
  final ColorScheme light;
}
