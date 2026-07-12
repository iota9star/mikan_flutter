import 'package:easy_refresh/easy_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/core/common/delegate.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/kit.dart';
import 'package:mikan/core/models/fonts.dart';
import 'package:mikan/core/widgets/ripple_tap.dart';
import 'package:mikan/core/widgets/scalable_tap.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';
import 'package:mikan/features/settings/application/fonts_provider.dart';

@FFRoute(name: '/fonts')
class FontsPage extends ConsumerWidget {
  const FontsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fonts = ref.watch(fontsProvider.select((s) => s.fonts));
    final loading = ref.watch(fontsProvider.select((s) => s.loading));

    return Scaffold(
      body: EasyRefresh(
        onRefresh: () => ref.read(fontsProvider.notifier).load(),
        header: defaultHeader,
        refreshOnStart: true,
        child: CustomScrollView(
          slivers: [
            SliverPinnedAppBar(
              title: '字体管理',
              actions: [
                Tooltip(
                  message: '重置默认字体',
                  child: IconButton(
                    icon: const Icon(Icons.restart_alt_rounded),
                    onPressed: () => ref.read(fontsProvider.notifier).resetDefaultFont(),
                  ),
                ),
              ],
            ),
            if (loading && fonts.isEmpty)
              const SliverToBoxAdapter(child: Center(child: ExpressiveLoadingIndicator()))
            else if (fonts.isEmpty)
              SliverToBoxAdapter(
                child: Center(child: Text('暂无字体', style: Theme.of(context).textTheme.bodyLarge)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverWaterfallFlow(
                  gridDelegate: SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
                    minCrossAxisExtent: 250.0,
                    mainAxisSpacing: context.margins,
                    crossAxisSpacing: context.margins,
                  ),
                  delegate: SliverChildBuilderDelegate((_, index) {
                    final font = fonts[index];
                    return FontItemCard(font: font);
                  }, childCount: fonts.length),
                ),
              ),
            sliverGapH24WithNavBarHeight(context),
          ],
        ),
      ),
    );
  }
}

class FontItemCard extends ConsumerWidget {
  const FontItemCard({super.key, required this.font});

  final Font font;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.labelSmall;
    final style1 = baseStyle?.copyWith(color: theme.colorScheme.onTertiaryContainer);
    final style2 = baseStyle?.copyWith(color: theme.colorScheme.onSecondaryContainer);

    return ScalableCard(
      onTap: () {
        ref.read(fontsProvider.notifier).enableFont(font);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    font.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const Gap(4),
                FontProgressIndicator(fontId: font.id),
              ],
            ),
            const Gap(4),
            Row(
              children: [
                RippleTap(
                  onTap: () {},
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    child: Text('${font.files.length}个字体', style: style1),
                  ),
                ),
                const Gap(4),
                RippleTap(
                  onTap: font.official.launchAppAndCopy,
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    child: Text('官网', style: style2),
                  ),
                ),
                const Gap(4),
                RippleTap(
                  onTap: font.license.url.launchAppAndCopy,
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    child: Text(font.license.name, style: style2),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Text(font.desc, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class FontProgressIndicator extends ConsumerWidget {
  const FontProgressIndicator({super.key, required this.fontId});

  final String fontId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(fontProgressProvider(fontId));
    final usedId = ref.watch(usedFontFamilyIdProvider);

    if (event == null) {
      return const SizedBox();
    }
    if (event.percent == 1.0) {
      if (usedId == fontId) {
        return const Icon(Icons.check_circle_outline_rounded);
      } else {
        return const SizedBox();
      }
    }
    return const ExpressiveLoadingIndicator(constraints: BoxConstraints.tightFor(width: 16, height: 16));
  }
}
