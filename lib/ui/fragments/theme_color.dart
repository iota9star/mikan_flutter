import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../internal/hive.dart';
import '../../topvars.dart';
import '../../widget/sliver_pinned_header.dart';

class ThemeColorPanel extends StatelessWidget {
  const ThemeColorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverPinnedAppBar(
            title: '选择主题色',
            borderRadius: borderRadiusT28,
            bottomBorder: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: edgeH24V8,
              child: ValueListenableBuilder(
                valueListenable: MyHive.settings.listenable(
                  keys: [SettingsHiveKey.colorSeed],
                ),
                builder: (context, _, child) {
                  final color = Color(MyHive.getColorSeed());
                  return ColorPicker(
                    color: color,
                    padding: EdgeInsets.zero,
                    pickersEnabled: const <ColorPickerType, bool>{
                      ColorPickerType.both: true,
                      ColorPickerType.primary: false,
                      ColorPickerType.accent: false,
                      ColorPickerType.bw: false,
                      ColorPickerType.custom: true,
                      ColorPickerType.wheel: true,
                    },
                    enableShadesSelection: false,
                    pickerTypeTextStyle: theme.textTheme.labelLarge,
                    onColorChanged: MyHive.setColorSeed,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
