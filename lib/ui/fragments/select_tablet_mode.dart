import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../internal/hive.dart';
import '../../internal/kit.dart';
import '../../widget/sliver_pinned_header.dart';

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

class TabletModeBuilder extends StatefulWidget {
  const TabletModeBuilder({super.key, required this.builder, this.child});

  final ValueWidgetBuilder<bool> builder;
  final Widget? child;

  @override
  State<TabletModeBuilder> createState() => _TabletModeBuilderState();
}

class _TabletModeBuilderState extends State<TabletModeBuilder> {
  ValueListenable<Box>? _listenable;
  bool? _lastIsTablet;

  @override
  void initState() {
    super.initState();
    _listenable = MyHive.settings.listenable(keys: [SettingsHiveKey.tabletMode]);
  }

  void _updateIsTablet() {
    if (mounted) {
      final currentIsTablet = context.useTabletLayout;
      if (_lastIsTablet != currentIsTablet) {
        _lastIsTablet = currentIsTablet;
        setState(() {});
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIsTablet();
  }

  @override
  void dispose() {
    _listenable?.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    _updateIsTablet();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.useTabletLayout;
    return widget.builder(context, isTablet, widget.child);
  }
}
