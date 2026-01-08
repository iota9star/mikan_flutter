import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../internal/dynamic_color.dart';
import '../internal/hive.dart';
import '../internal/lifecycle.dart';

class ThemeProvider extends StatefulWidget {
  const ThemeProvider({super.key, required this.builder});

  final Widget Function(ThemeMode mode, ColorScheme lightColorScheme, ColorScheme darkColorScheme, String? fontFamily)
  builder;

  @override
  State<ThemeProvider> createState() => _ThemeProviderState();
}

base class _ThemeProviderState extends LifecycleAppState<ThemeProvider> {
  final _colorSchemePair = ValueNotifier<ColorSchemePair?>(null);

  @override
  void initState() {
    super.initState();
    _tryGetDynamicColor();
  }

  void _tryGetDynamicColor() {
    getDynamicColorScheme().then((value) {
      _colorSchemePair.value = value;
      if (MyHive.dynamicColorEnabled() && value == null) {
        MyHive.enableDynamicColor(false);
      }
    });
  }

  @override
  void onResume() {
    _tryGetDynamicColor();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _colorSchemePair,
      builder: (context, pair, child) {
        return ValueListenableBuilder(
          valueListenable: MyHive.settings.listenable(
            keys: [
              SettingsHiveKey.fontFamily,
              SettingsHiveKey.themeMode,
              SettingsHiveKey.dynamicColor,
              SettingsHiveKey.colorSeed,
            ],
          ),
          builder: (context, _, child) {
            final fontFamily = MyHive.getFontFamily()?.value;
            final themeMode = MyHive.getThemeMode();
            final dynamicColorEnabled = MyHive.dynamicColorEnabled();
            if (dynamicColorEnabled && pair != null) {
              return widget.builder.call(themeMode, pair.light, pair.dark, fontFamily);
            }
            final colorSeed = Color(MyHive.getColorSeed());
            return widget.builder.call(
              themeMode,
              ColorScheme.fromSeed(seedColor: colorSeed),
              ColorScheme.fromSeed(seedColor: colorSeed, brightness: Brightness.dark),
              fontFamily,
            );
          },
        );
      },
    );
  }
}
