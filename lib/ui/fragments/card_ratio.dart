import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../internal/delegate.dart';
import '../../internal/hive.dart';
import '../../topvars.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/sliver_pinned_header.dart';

class CardRatio extends StatelessWidget {
  const CardRatio({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratios = [
      0.5,
      0.55,
      0.6,
      0.65,
      0.7,
      0.75,
      0.8,
      0.85,
      0.9,
      0.95,
      1.0,
      1.05,
    ];
    ratios.shuffle();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverPinnedAppBar(title: '卡片比例'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            sliver: ValueListenableBuilder(
              valueListenable: MyHive.settings.listenable(
                keys: [SettingsHiveKey.cardRatio],
              ),
              builder: (context, _, child) {
                final selected = MyHive.getCardRatio();
                return SliverWaterfallFlow(
                  gridDelegate:
                      const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    minCrossAxisExtent: 120.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ratio = ratios[index];
                      final isSelected = selected == ratio;
                      final color = isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary;
                      return Column(
                        children: [
                          RippleTap(
                            borderRadius: borderRadius12,
                            onTap: () {
                              MyHive.setCardRatio(ratio);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AspectRatio(
                                aspectRatio: ratio - 0.05,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Card(
                                            margin: EdgeInsets.zero,
                                            color: theme
                                                .colorScheme.secondaryContainer,
                                            child: Container(),
                                          ),
                                          PositionedDirectional(
                                            end: 12.0,
                                            top: 12.0,
                                            child: Container(
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: color,
                                                shape: const StadiumBorder(),
                                              ),
                                              padding: edgeH6V2,
                                              child: Text(
                                                ratio.toString(),
                                                style: theme
                                                    .textTheme.labelMedium
                                                    ?.copyWith(
                                                  color: isSelected
                                                      ? theme
                                                          .colorScheme.onPrimary
                                                      : theme.colorScheme
                                                          .onSecondary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    sizedBoxH4,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '你好，Mikan',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    theme.textTheme.titleSmall,
                                              ),
                                              Text(
                                                '2099/12/31',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            isSelected
                                                ? Icons.favorite_rounded
                                                : Icons
                                                    .favorite_outline_rounded,
                                            color: color,
                                          ),
                                          onPressed: null,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    childCount: ratios.length,
                  ),
                );
              },
            ),
          ),
          sliverSizedBoxH24WithNavBarHeight(context),
        ],
      ),
    );
  }
}
