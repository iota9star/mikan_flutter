import 'dart:math' as math;

import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/mutation.dart';

import 'package:mikan/res/assets.gen.dart';
import 'package:mikan/features/bangumi/presentation/pages/bangumi.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/common/image_provider.dart';
import 'package:mikan/core/common/kit.dart';
import 'package:mikan/core/models/bangumi.dart' as model;
import 'package:mikan/features/subscription/application/subscription_service.dart'
    show subscribeBangumi, subscribeMutation;
import 'package:mikan/core/widgets/scalable_tap.dart';
import 'package:mikan/core/widgets/transition_container.dart';

/// Provider for current bangumi - will be overridden
final currentBangumiProvider = Provider<model.Bangumi>((ref) {
  throw UnimplementedError('Must be overridden');
});

/// Provider for bangumis list - will be overridden
final bangumisListProvider = Provider<List<model.Bangumi>>((ref) {
  throw UnimplementedError('Must be overridden');
});

final cardStyleProvider = Provider<int>((ref) {
  throw UnimplementedError('Must be overridden');
});

@immutable
class SliverBangumiList extends ConsumerWidget {
  const SliverBangumiList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final margins = context.margins;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      sliver: ValueListenableBuilder(
        valueListenable: MyHive.settings.listenable(
          keys: [SettingsHiveKey.cardRatio, SettingsHiveKey.cardStyle, SettingsHiveKey.cardWidth],
        ),
        builder: (context, _, child) {
          final cardRatio = MyHive.getCardRatio().toDouble();
          final cardWidth = MyHive.getCardWidth().toDouble();
          final cardStyle = MyHive.getCardStyle();
          final bangumis = ref.watch(bangumisListProvider);
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              crossAxisSpacing: margins,
              mainAxisSpacing: margins,
              maxCrossAxisExtent: cardWidth,
              childAspectRatio: cardRatio,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final bangumi = bangumis[index];
              return ProviderScope(
                overrides: [
                  cardStyleProvider.overrideWithValue(cardStyle),
                  currentBangumiProvider.overrideWithValue(bangumi),
                ],
                child: const _BangumiItem(),
              );
            }, childCount: bangumis.length),
          );
        },
      ),
    );
  }
}

/// Main item widget - const, reads everything from providers
class _BangumiItem extends ConsumerWidget {
  const _BangumiItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardStyle = ref.watch(cardStyleProvider);

    return switch (cardStyle) {
      2 => const _BangumiItemStyle2(),
      3 => const _BangumiItemStyle3(),
      4 => const _BangumiItemStyle4(),
      _ => const _BangumiItemStyle1(),
    };
  }
}

/// Style 1
class _BangumiItemStyle1 extends ConsumerWidget {
  const _BangumiItemStyle1();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangumi = ref.watch(currentBangumiProvider);
    final cover = _BangumiItemCover(bangumi: bangumi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _BangumiTransitionContainer(
            child: bangumi.grey || (bangumi.num == null || bangumi.num == 0)
                ? cover
                : Stack(
                    children: [
                      Positioned.fill(child: cover),
                      PositionedDirectional(top: 12.0, end: 12.0, child: _BangumiNumBadge(num: bangumi.num!)),
                    ],
                  ),
          ),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(child: _BangumiInfo(bangumi: bangumi)),
            Transform.translate(
              offset: const Offset(8.0, 0.0),
              child: _SubscribeButton(bangumi: bangumi),
            ),
          ],
        ),
        const Gap(8),
      ],
    );
  }
}

/// Style 2
class _BangumiItemStyle2 extends ConsumerWidget {
  const _BangumiItemStyle2();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangumi = ref.watch(currentBangumiProvider);
    final cover = _BangumiItemCover(bangumi: bangumi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _BangumiTransitionContainer(
            child: bangumi.grey
                ? cover
                : Stack(
                    children: [
                      Positioned.fill(child: cover),
                      PositionedDirectional(top: 4.0, end: 4.0, child: _BangumiActionBar(bangumi: bangumi)),
                    ],
                  ),
          ),
        ),
        const Gap(12),
        _BangumiInfo(bangumi: bangumi),
        const Gap(8),
      ],
    );
  }
}

/// Style 3
class _BangumiItemStyle3 extends ConsumerWidget {
  const _BangumiItemStyle3();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangumi = ref.watch(currentBangumiProvider);
    final cover = Container(
      foregroundDecoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black45],
          stops: [0.5, 1.0],
        ),
      ),
      child: _BangumiItemCover(bangumi: bangumi),
    );

    return _BangumiTransitionContainer(
      child: Stack(
        children: [
          Positioned.fill(child: cover),
          PositionedDirectional(top: 4.0, end: 4.0, child: _BangumiActionBar(bangumi: bangumi)),
          PositionedDirectional(
            bottom: 12.0,
            start: 12.0,
            end: 12.0,
            child: _BangumiInfo(bangumi: bangumi, whiteText: true),
          ),
        ],
      ),
    );
  }
}

/// Style 4
class _BangumiItemStyle4 extends ConsumerWidget {
  const _BangumiItemStyle4();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangumi = ref.watch(currentBangumiProvider);
    final cover = _BangumiItemCover(bangumi: bangumi);

    return _BangumiTransitionContainer(
      child: Stack(
        children: [
          Positioned.fill(child: cover),
          PositionedDirectional(top: 4.0, end: 4.0, child: _BangumiActionBar(bangumi: bangumi)),
        ],
      ),
    );
  }
}

/// Transition container wrapper - reads data from providers
class _BangumiTransitionContainer extends ConsumerWidget {
  const _BangumiTransitionContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangumi = ref.watch(currentBangumiProvider);

    return TransitionContainer(
      next: BangumiPage(bangumiId: bangumi.id, cover: bangumi.cover, name: bangumi.name),
      routeSettings: const RouteSettings(name: '/bangumi'),
      builder: (context, open) {
        return ScalableCard(
          onTap: () {
            if (bangumi.grey) {
              '此番组下暂无作品'.toast();
            } else {
              open();
            }
          },
          child: child,
        );
      },
    );
  }
}

/// Cover image
class _BangumiItemCover extends StatelessWidget {
  const _BangumiItemCover({required this.bangumi});

  final model.Bangumi bangumi;

  @override
  Widget build(BuildContext context) {
    final margins = context.margins;
    final size = calcGridItemSizeWithMaxCrossAxisExtent(
      crossAxisExtent: context.screenWidth - 48.0,
      maxCrossAxisExtent: MyHive.getCardWidth().toDouble(),
      crossAxisSpacing: margins,
      childAspectRatio: MyHive.getCardRatio().toDouble(),
    );
    final imageWidth = (size.width * context.devicePixelRatio).ceil();

    final image = Image(
      image: ResizeImage(CacheImage(bangumi.cover), width: imageWidth),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: child,
        );
      },
      errorBuilder: (_, __, ___) => const _BangumiItemErrorPlaceholder(),
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );

    return bangumi.grey
        ? ColorFiltered(colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation), child: image)
        : image;
  }
}

/// Subscribe button - reads data from providers
class _SubscribeButton extends ConsumerWidget {
  const _SubscribeButton({required this.bangumi});

  final model.Bangumi bangumi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscribeState = ref.watch(subscribeMutation(bangumi.id));

    if (subscribeState is MutationPending) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: ExpressiveLoadingIndicator(constraints: BoxConstraints.tightFor(width: 24.0, height: 24.0)),
      );
    }

    return bangumi.subscribed
        ? IconButton(
            tooltip: '取消订阅',
            icon: const Icon(Icons.favorite_rounded),
            color: Theme.of(context).colorScheme.error,
            visualDensity: VisualDensity.compact,
            onPressed: () => subscribeBangumi(ref, bangumi.id, bangumi.subscribed),
          )
        : IconButton(
            tooltip: '订阅',
            icon: const Icon(Icons.favorite_border_rounded),
            color: Theme.of(context).colorScheme.error,
            visualDensity: VisualDensity.compact,
            onPressed: () => subscribeBangumi(ref, bangumi.id, bangumi.subscribed),
          );
  }
}

/// Bangumi info - reads data from providers
class _BangumiInfo extends StatelessWidget {
  const _BangumiInfo({required this.bangumi, this.whiteText = false});

  final model.Bangumi bangumi;
  final bool whiteText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bangumi.updateAt.isNotBlank)
          Text(
            bangumi.updateAt,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: whiteText ? Colors.white : null),
          ),
        Text(
          bangumi.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(color: whiteText ? Colors.white : null),
        ),
      ],
    );
  }
}

/// Action bar - reads data from providers
class _BangumiActionBar extends ConsumerWidget {
  const _BangumiActionBar({required this.bangumi});

  final model.Bangumi bangumi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        if (bangumi.num != null && bangumi.num! > 0) _BangumiNumBadge(num: bangumi.num!),
        if (!bangumi.grey) _SubscribeButton(bangumi: bangumi),
      ],
    );
  }
}

/// Num badge
class _BangumiNumBadge extends StatelessWidget {
  const _BangumiNumBadge({required this.num});

  final int num;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(color: theme.colorScheme.error, shape: const StadiumBorder()),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      child: Text(
        num > 99 ? '99+' : '+$num',
        style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onError, height: 1.25),
      ),
    );
  }
}

/// Error placeholder
class _BangumiItemErrorPlaceholder extends StatelessWidget {
  const _BangumiItemErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.mikan.provider(),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.color),
        ),
      ),
    );
  }
}

Size calcGridItemSizeWithMaxCrossAxisExtent({
  required double crossAxisExtent,
  required double maxCrossAxisExtent,
  required double crossAxisSpacing,
  required double childAspectRatio,
}) {
  int crossAxisCount = (crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing)).ceil();
  crossAxisCount = math.max(1, crossAxisCount);
  final double usableCrossAxisExtent = math.max(0.0, crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1));
  final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
  final double childMainAxisExtent = childCrossAxisExtent / childAspectRatio;
  return Size(childCrossAxisExtent, childMainAxisExtent);
}
