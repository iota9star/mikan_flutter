import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../internal/hive.dart';
import '../../topvars.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/scalable_tap.dart';
import '../../widget/sliver_pinned_header.dart';

class CardStyle extends StatelessWidget {
  const CardStyle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverPinnedAppBar(title: '卡片样式'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            sliver: ValueListenableBuilder(
              valueListenable: MyHive.settings.listenable(
                keys: [SettingsHiveKey.cardStyle, SettingsHiveKey.cardRatio],
              ),
              builder: (context, _, child) {
                final selected = MyHive.getCardStyle();
                final ratio = MyHive.getCardRatio();
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    crossAxisCount: 3,
                    childAspectRatio: ratio,
                  ),
                  delegate: SliverChildListDelegate([
                    _style1(theme, selected == 1),
                    _style2(theme, selected == 2),
                    _style3(theme, selected == 3),
                  ]),
                );
              },
            ),
          ),
          sliverSizedBoxH24WithNavBarHeight(context),
        ],
      ),
    );
  }

  Widget _style3(
    ThemeData theme,
    bool isSelected,
  ) {
    final color =
        isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary;
    return RippleTap(
      borderRadius: borderRadius12,
      onTap: () {
        MyHive.setCardStyle(3);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ScalableCard(
                    onTap: () {  },
                    child: const SizedBox.expand(),
                  ),
                  PositionedDirectional(
                    start: 12.0,
                    top: 12.0,
                    child: Icon(
                      isSelected
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      color: color,
                    ),
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
                        '样式3',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSecondary,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 12.0,
                    start: 12.0,
                    end: 12.0,
                    child: Column(
                      children: [
                        Text(
                          '你好，Mikan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          '2099/12/31',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _style2(
    ThemeData theme,
    bool isSelected,
  ) {
    final color =
        isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary;
    return RippleTap(
      borderRadius: borderRadius12,
      onTap: () {
        MyHive.setCardStyle(2);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ScalableCard(
                    onTap: () {  },
                    child: const SizedBox.expand(),
                  ),
                  PositionedDirectional(
                    start: 12.0,
                    top: 12.0,
                    child: Icon(
                      isSelected
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      color: color,
                    ),
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
                        '样式2',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSecondary,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            sizedBoxH4,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '你好，Mikan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  '2099/12/31',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _style1(
    ThemeData theme,
    bool isSelected,
  ) {
    final color =
        isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary;
    return RippleTap(
      borderRadius: borderRadius12,
      onTap: () {
        MyHive.setCardStyle(1);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ScalableCard(
                    onTap: () {  },
                    child: const SizedBox.expand(),
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
                        '样式1',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSecondary,
                          height: 1.25,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '你好，Mikan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '2099/12/31',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isSelected
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                    color: color,
                  ),
                  onPressed: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
