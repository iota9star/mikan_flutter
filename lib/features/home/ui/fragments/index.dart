import 'dart:async';
import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../../../shared/internal/extension.dart';
import '../../../../shared/internal/image_provider.dart';
import '../../../../shared/internal/kit.dart';
import '../../../../shared/models/bangumi_row.dart';
import '../../../../shared/models/carousel.dart';
import '../../../../shared/ui/components/simple_record_item.dart' show SimpleRecordItem, currentRecordProvider;
import '../../../../shared/ui/fragments/select_season.dart';
import '../../../../shared/ui/fragments/select_tablet_mode.dart';
import '../../../../shared/ui/fragments/settings.dart';
import '../../../../shared/ui/fragments/sliver_bangumi_list.dart';
import '../../../../shared/widgets/bottom_sheet.dart';
import '../../../../shared/widgets/ripple_tap.dart';
import '../../../../shared/widgets/sliver_pinned_header.dart';
import '../../../../shared/widgets/transition_container.dart';
import '../../../../topvars.dart';
import '../../../bangumi/ui/bangumi.dart';
import '../../../search/ui/search.dart';
import '../../providers/index_provider.dart';

class IndexFragment extends ConsumerStatefulWidget {
  const IndexFragment({super.key});

  @override
  ConsumerState<IndexFragment> createState() => _IndexFragmentState();
}

class _IndexFragmentState extends ConsumerState<IndexFragment> with WidgetsBindingObserver {
  final _infiniteScrollController = InfiniteScrollController();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _newTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _newTimer();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _infiniteScrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _newTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 3600), (timer) {
      if (!_infiniteScrollController.hasClients) {
        return;
      }
      _infiniteScrollController.animateToItem(
        (_infiniteScrollController.offset / 300.0).round() + 1,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final indexAsync = ref.watch(indexProvider);

    return Scaffold(
      body: EasyRefresh.builder(
        onRefresh: () => ref.read(indexProvider.notifier).refresh(),
        header: defaultHeader,
        childBuilder: (context, physics) {
          return indexAsync.when(
            data: (indexData) {
              return CustomScrollView(
                physics: physics,
                slivers: [
                  const _PinedHeader(),
                  _CarouselSection(indexData: indexData, controller: _infiniteScrollController),
                  ..._buildBangumiRowsSlivers(indexData.bangumiRows),
                  _OVASection(indexData: indexData),
                  sliverGapH120WithNavBarHeight(context),
                ],
              );
            },
            loading: () => CustomScrollView(
              physics: physics,
              slivers: const [
                _PinedHeader(),
                SliverFillRemaining(child: Center(child: defaultLoadingWidget)),
              ],
            ),
            error: (error, stack) => CustomScrollView(
              physics: physics,
              slivers: [
                const _PinedHeader(),
                SliverFillRemaining(child: Center(child: Text('加载失败: $error'))),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Builds a list of MultiSliver widgets for bangumi rows
/// Used directly in CustomScrollView.slivers via spread operator
List<Widget> _buildBangumiRowsSlivers(List<BangumiRow> bangumiRows) {
  return bangumiRows.map((bangumiRow) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [_BangumiRowSection(key: ValueKey(bangumiRow.name), bangumiRow: bangumiRow)],
    );
  }).toList();
}

/// Extracted widget for each bangumi row section
/// This allows each section to rebuild independently when its data changes
class _BangumiRowSection extends StatelessWidget {
  const _BangumiRowSection({super.key, required this.bangumiRow});

  final BangumiRow bangumiRow;

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        _WeekSectionHeader(bangumiRow: bangumiRow),
        ProviderScope(
          overrides: [bangumisListProvider.overrideWithValue(bangumiRow.bangumis)],
          child: const SliverBangumiList(),
        ),
      ],
    );
  }
}

/// Extracted header widget for week sections
/// Uses const constructors where possible for better performance
class _WeekSectionHeader extends StatelessWidget {
  const _WeekSectionHeader({required this.bangumiRow});

  final BangumiRow bangumiRow;

  String _buildSimpleSummary() {
    return [
      if (bangumiRow.updatedNum > 0) '🚀 ${bangumiRow.updatedNum}部',
      if (bangumiRow.subscribedUpdatedNum > 0) '💖 ${bangumiRow.subscribedUpdatedNum}部',
      if (bangumiRow.subscribedNum > 0) '❤ ${bangumiRow.subscribedNum}部',
      '🎬 ${bangumiRow.num}部',
    ].join('，');
  }

  String _buildFullSummary() {
    return [
      if (bangumiRow.updatedNum > 0) '更新${bangumiRow.updatedNum}部',
      if (bangumiRow.subscribedUpdatedNum > 0) '订阅更新${bangumiRow.subscribedUpdatedNum}部',
      if (bangumiRow.subscribedNum > 0) '订阅${bangumiRow.subscribedNum}部',
      '共${bangumiRow.num}部',
    ].join('，');
  }

  @override
  Widget build(BuildContext context) {
    final simple = _buildSimpleSummary();
    final full = _buildFullSummary();
    final theme = Theme.of(context);

    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          height: 48.0,
          decoration: BoxDecoration(color: theme.colorScheme.surface),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  bangumiRow.name,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tooltip(
                message: full,
                child: Text(simple, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extracted carousel section
/// Separated to prevent rebuilding carousel when other content changes
class _CarouselSection extends StatelessWidget {
  const _CarouselSection({required this.indexData, required this.controller});

  final IndexData indexData;
  final InfiniteScrollController controller;

  @override
  Widget build(BuildContext context) {
    final carousels = indexData.carousels;
    if (carousels.isEmpty) {
      return emptySliverToBoxAdapter;
    }
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 160.0,
        child: InfiniteCarousel.builder(
          itemBuilder: (context, index, realIndex) {
            return _CarouselItem(carousel: carousels[index], controller: controller, realIndex: realIndex);
          },
          controller: controller,
          itemExtent: 300.0,
          itemCount: carousels.length,
          center: false,
          velocityFactor: 0.8,
        ),
      ),
    );
  }
}

/// Individual carousel item widget
/// Extracted to optimize rebuild performance during animation
class _CarouselItem extends StatelessWidget {
  const _CarouselItem({required this.carousel, required this.controller, required this.realIndex});

  final Carousel carousel;
  final InfiniteScrollController controller;
  final int realIndex;

  @override
  Widget build(BuildContext context) {
    final currentOffset = 300.0 * realIndex;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final diff = controller.offset - currentOffset;
        final ver = (diff / 36.0).abs();
        return Padding(
          padding: EdgeInsetsDirectional.only(start: 24.0, top: (ver > 12.0 ? 12.0 : ver), bottom: 8.0),
          child: TransitionContainer(
            routeSettings: const RouteSettings(name: '/bangumi'),
            builder: (context, open) {
              return RippleTap(
                onTap: open,
                child: Image(fit: BoxFit.cover, image: CacheImage(carousel.cover)),
              );
            },
            next: BangumiPage(bangumiId: carousel.id, cover: carousel.cover),
          ),
        );
      },
    );
  }
}

/// Extracted OVA section
/// Rebuilds independently when OVA data changes
class _OVASection extends StatelessWidget {
  const _OVASection({required this.indexData});

  final IndexData indexData;

  @override
  Widget build(BuildContext context) {
    final records = indexData.ovas;
    if (records.isEmpty) {
      return emptySliverToBoxAdapter;
    }
    final simple = '🚀 ${records.length}条';
    final full = '更新${records.length}条记录';
    final theme = Theme.of(context);

    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '最近更新 • 剧场版/OVA',
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tooltip(
                  message: full,
                  child: Text(simple, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
        Builder(
          builder: (context) {
            final margins = context.margins;
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              sliver: SliverWaterfallFlow(
                gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                  crossAxisSpacing: margins,
                  mainAxisSpacing: margins,
                  maxCrossAxisExtent: 400.0,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final record = records[index];
                  return ProviderScope(
                    overrides: [currentRecordProvider.overrideWithValue(record)],
                    child: const SimpleRecordItem(),
                  );
                }, childCount: records.length),
              ),
            );
          },
        ),
      ],
    );
  }
}

void showSettingsPanel(BuildContext context) {
  MBottomSheet.show(context, (context) => const MBottomSheet(child: SettingsPanel()));
}

void showYearSeasonBottomSheet(BuildContext context) {
  MBottomSheet.show(context, (context) => const MBottomSheet(child: SelectSeasonFragment()));
}

/// Index Header - 监听selectedSeason和user
class _PinedHeader extends ConsumerWidget {
  const _PinedHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用select只监听需要的字段，避免因其他字段变化而重建
    final selectedSeason = ref.watch(indexProvider.select((s) => s.value?.selectedSeason));
    final user = ref.watch(indexProvider.select((s) => s.value?.user));
    const appbarHeight = 64.0;
    final statusBarHeight = context.statusBarHeight;
    final maxHeight = statusBarHeight + 180.0;
    final minHeight = statusBarHeight + appbarHeight;
    final offsetHeight = maxHeight - minHeight;
    final theme = Theme.of(context);

    return TabletModeBuilder(
      builder: (context, isTablet, child) {
        return SliverPersistentHeader(
          pinned: true,
          delegate: WrapSliverPersistentHeaderDelegate(
            maxExtent: maxHeight,
            minExtent: minHeight,
            onBuild: (BuildContext context, double shrinkOffset, bool overlapsContent) {
              final offsetRatio = math.min(shrinkOffset / offsetHeight, 1.0);
              final display = offsetRatio >= 0.8;
              final children = <Widget>[
                if (display)
                  RippleTap(
                    onTap: () {
                      showYearSeasonBottomSheet(context);
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        children: [
                          if (selectedSeason != null)
                            Text(selectedSeason.title, style: theme.textTheme.titleLarge)
                          else
                            const SizedBox(),
                          const Gap(8),
                          const Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
              ];
              if (!isTablet) {
                children.add(
                  TransitionContainer(
                    next: const SearchPage(),
                    routeSettings: const RouteSettings(name: '/search'),
                    builder: (context, open) {
                      return RippleTap(
                        onTap: open,
                        shape: const CircleBorder(),
                        child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.search_rounded)),
                      );
                    },
                  ),
                );
                children.add(buildAvatarWithAction(context));
              }
              final withoutName = user?.name.isNullOrBlank ?? true;
              final userName = user?.name;
              return Stack(
                children: [
                  PositionedDirectional(
                    start: 12.0,
                    bottom: 12.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            withoutName ? 'Mikan Project' : 'Hi, $userName',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        RippleTap(
                          onTap: () {
                            showYearSeasonBottomSheet(context);
                          },
                          borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                if (selectedSeason != null)
                                  Text(selectedSeason.title, style: theme.textTheme.headlineMedium)
                                else
                                  const SizedBox(),
                                const Gap(8),
                                const Icon(Icons.keyboard_arrow_down_rounded),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    top: 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: offsetRatio > 0.1
                            ? Border(
                                bottom: Divider.createBorderSide(
                                  context,
                                  color: theme.colorScheme.outlineVariant,
                                  width: 0.0,
                                ),
                              )
                            : null,
                      ),
                      padding: EdgeInsetsDirectional.only(start: 12.0, end: 12.0, top: statusBarHeight),
                      height: statusBarHeight + appbarHeight,
                      child: Row(children: children),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
