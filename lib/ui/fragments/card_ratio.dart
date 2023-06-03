import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../internal/hive.dart';
import '../../topvars.dart';
import '../../widget/sliver_pinned_header.dart';

class CardRatio extends StatelessWidget {
  const CardRatio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverPinnedAppBar(
            title: '卡片比例',
            maxExtent: 120.0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ValueListenableBuilder(
                valueListenable: MyHive.settings.listenable(
                  keys: [SettingsHiveKey.cardRatio],
                ),
                builder: (context, _, child) {
                  final value = MyHive.getCardRatio();
                  return Slider(
                    value: value.toDouble(),
                    onChanged: (v) {
                      MyHive.setCardRatio(Decimal.parse(v.toString()));
                    },
                    min: 0.4,
                    max: 1.2,
                    divisions: 40,
                    label: value.toStringAsFixed(2),
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
