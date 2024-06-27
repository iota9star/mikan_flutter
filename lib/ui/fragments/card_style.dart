import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../internal/hive.dart';
import '../../topvars.dart';
import '../../widget/sliver_pinned_header.dart';

class CardStyle extends StatelessWidget {
  const CardStyle({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverPinnedAppBar(
            title: '卡片样式',
            maxExtent: 120.0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ValueListenableBuilder(
                valueListenable: MyHive.settings.listenable(
                  keys: [SettingsHiveKey.cardStyle],
                ),
                builder: (context, _, child) {
                  final value = MyHive.getCardStyle();
                  return SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: List.generate(4, (index) {
                      final v = index + 1;
                      return ButtonSegment(
                        value: v,
                        label: Text('样式$v'),
                      );
                    }),
                    onSelectionChanged: (v) {
                      MyHive.setCardStyle(v.first);
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.resolveWith((states) {
                        return const RoundedRectangleBorder(
                          borderRadius: borderRadius6,
                        );
                      }),
                    ),
                    selected: {value},
                  );
                },
              ),
            ),
          ),
          sliverSizedBoxH24WithNavBarHeight(context),
        ],
      ),
    );
  }
}
