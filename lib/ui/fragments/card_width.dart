import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../internal/hive.dart';
import '../../topvars.dart';
import '../../widget/sliver_pinned_header.dart';

class CardWidth extends StatelessWidget {
  const CardWidth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverPinnedAppBar(
            title: '卡片宽度',
            maxExtent: 120.0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ValueListenableBuilder(
                valueListenable: MyHive.settings.listenable(
                  keys: [SettingsHiveKey.cardWidth],
                ),
                builder: (context, _, child) {
                  final cardWidth = MyHive.getCardWidth();
                  return Slider(
                    value: cardWidth.toDouble(),
                    onChanged: (v) {
                      MyHive.setCardWidth(Decimal.parse(v.toString()));
                    },
                    min: 100.0,
                    max: 400.0,
                    divisions: 15,
                    label: cardWidth.toStringAsFixed(0),
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
