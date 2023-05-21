import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../internal/hive.dart';
import '../../internal/kit.dart';
import '../../topvars.dart';
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
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final mode = TabletMode.values[index];
                return RadioListTile<TabletMode>(
                  title: Text(mode.label),
                  value: mode,
                  groupValue: selectedMode,
                  onChanged: (value) {
                    MyHive.setTabletMode(mode);
                    Navigator.pop(context);
                  },
                );
              },
              childCount: TabletMode.values.length,
            ),
          ),
        ],
      ),
    );
  }
}

class TabletModeBuilder extends StatefulWidget {
  const TabletModeBuilder({
    super.key,
    required this.builder,
    this.child,
  });

  final ValueWidgetBuilder<bool> builder;
  final Widget? child;

  @override
  State<TabletModeBuilder> createState() => _TabletModeBuilderState();
}

class _TabletModeBuilderState extends State<TabletModeBuilder> {
  ValueListenable<Box>? _listenable;

  final _isTablet = ValueNotifier(navKey.currentContext!.useTabletLayout);

  @override
  void initState() {
    super.initState();
    _listenable = MyHive.settings.listenable(
      keys: [SettingsHiveKey.tabletMode],
    )..addListener(_onChange);
  }

  void _onChange() {
    if (mounted) {
      _isTablet.value = navKey.currentContext!.useTabletLayout;
    }
  }

  @override
  void dispose() {
    _listenable?.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isTablet,
      builder: (context, isTablet, child) {
        return widget.builder(context, isTablet, child);
      },
      child: widget.child,
    );
  }
}
