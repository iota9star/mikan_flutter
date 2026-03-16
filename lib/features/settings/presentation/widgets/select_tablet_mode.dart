import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/common/kit.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';

class SelectTabletMode extends StatelessWidget {
  const SelectTabletMode({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedMode = MyHive.getTabletMode();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverPinnedAppBar(title: '平板模式'),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final mode = TabletMode.values[index];
              return RadioListTile<TabletMode>(
                title: Text(mode.label),
                value: mode,
                // ignore: deprecated_member_use
                groupValue: selectedMode,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  MyHive.setTabletMode(mode);
                  Navigator.pop(context);
                },
              );
            }, childCount: TabletMode.values.length),
          ),
        ],
      ),
    );
  }
}

class TabletModeBuilder extends StatelessWidget {
  const TabletModeBuilder({super.key, required this.builder, this.child});

  final ValueWidgetBuilder<bool> builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: MyHive.settings.listenable(keys: [SettingsHiveKey.tabletMode]),
      builder: (context, _, __) {
        final isTablet = context.useTabletLayout;
        return builder(context, isTablet, child);
      },
    );
  }
}
