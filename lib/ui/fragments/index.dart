import 'dart:async';
import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../internal/delegate.dart';
import '../../internal/extension.dart';
import '../../internal/image_provider.dart';
import '../../internal/kit.dart';
import '../../internal/lifecycle.dart';
import '../../mikan_routes.dart';
import '../../model/bangumi_row.dart';
import '../../model/carousel.dart';
import '../../model/record_item.dart';
import '../../model/season.dart';
import '../../model/user.dart';
import '../../providers/index_model.dart';
import '../../providers/op_model.dart';
import '../../topvars.dart';
import '../../widget/bottom_sheet.dart';
import '../../widget/infinite_carousel.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/scalable_tap.dart';
import '../../widget/sliver_pinned_header.dart';
import '../components/ova_record_item.dart';
import 'bangumi_sliver_grid.dart';
import 'select_season.dart';
import 'select_tablet_mode.dart';
import 'settings.dart';

class IndexFragment extends StatefulWidget {
  const IndexFragment({super.key});

  @override
  State<StatefulWidget> createState() => _IndexFragmentState();
}

class _IndexFragmentState extends LifecycleState<IndexFragment> {
  final _infiniteScrollController = InfiniteScrollController();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 3600), (timer) {
      _infiniteScrollController.animateToItem(
        (_infiniteScrollController.offset / 300.0).round() + 1,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _infiniteScrollController.dispose();
    super.dispose();
  }

  @override
  void onResume() {
    if (mounted) {
      Provider.of<IndexModel>(context, listen: false).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indexModel = Provider.of<IndexModel>(context, listen: false);
    return Scaffold(
      body: Selector<IndexModel, List<BangumiRow>>(
        selector: (_, model) => model.bangumiRows,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, bangumiRows, __) {
          return EasyRefresh.builder(
            onRefresh: indexModel.refresh,
            header: defaultHeader,
            childBuilder: (context, physics) {
              return CustomScrollView(
                physics: physics,
                slivers: [
                  const _PinedHeader(),
                  _buildCarousels(theme),
                  ...List.generate(
                    bangumiRows.length,
                    (index) {
                      final bangumiRow = bangumiRows[index];
                      return MultiSliver(
                        pushPinnedChildren: true,
                        children: [
                          _buildWeekSection(theme, bangumiRow),
                          BangumiSliverGridFragment(
                            bangumis: bangumiRow.bangumis,
                            handleSubscribe: (bangumi, flag) {
                              context.read<OpModel>().subscribeBangumi(
                                bangumi.id,
                                bangumi.subscribed,
                                onSuccess: () {
                                  bangumi.subscribed = !bangumi.subscribed;
                                  context
                                      .read<OpModel>()
                                      .subscribeChanged(flag);
                                },
                                onError: (msg) {
                                  '订阅失败：$msg'.toast();
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  _buildOVA(theme),
                  sliverSizedBoxH80WithNavBarHeight(context),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWeekSection(
    ThemeData theme,
    BangumiRow bangumiRow,
  ) {
    final simple = [
      if (bangumiRow.updatedNum > 0) '🚀 ${bangumiRow.updatedNum}部',
      if (bangumiRow.subscribedUpdatedNum > 0)
        '💖 ${bangumiRow.subscribedUpdatedNum}部',
      if (bangumiRow.subscribedNum > 0) '❤ ${bangumiRow.subscribedNum}部',
      '🎬 ${bangumiRow.num}部'
    ].join('，');
    final full = [
      if (bangumiRow.updatedNum > 0) '更新${bangumiRow.updatedNum}部',
      if (bangumiRow.subscribedUpdatedNum > 0)
        '订阅更新${bangumiRow.subscribedUpdatedNum}部',
      if (bangumiRow.subscribedNum > 0) '订阅${bangumiRow.subscribedNum}部',
      '共${bangumiRow.num}部'
    ].join('，');

    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          padding: edgeH24,
          height: 48.0,
          decoration: BoxDecoration(color: theme.colorScheme.background),
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
                child: Text(
                  simple,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarousels(ThemeData theme) {
    return Selector<IndexModel, List<Carousel>>(
      selector: (_, model) => model.carousels,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, carousels, __) {
        if (carousels.isNotEmpty) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 180.0,
              child: InfiniteCarousel.builder(
                itemBuilder: (context, index, realIndex) {
                  final carousel = carousels[index];
                  final String currFlag =
                      'carousel:$realIndex:${carousel.id}:${carousel.cover}';
                  final currentOffset = 300.0 * realIndex;
                  return AnimatedBuilder(
                    animation: _infiniteScrollController,
                    builder: (_, __) {
                      final diff =
                          _infiniteScrollController.offset - currentOffset;
                      final ver = (diff / 36.0).abs();
                      return Hero(
                        tag: currFlag,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: 24.0,
                            top: (ver > 12.0 ? 12.0 : ver) + 8,
                            bottom: 8.0,
                          ),
                          child: ScalableCard(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.bangumi.name,
                                arguments: Routes.bangumi.d(
                                  heroTag: currFlag,
                                  bangumiId: carousel.id,
                                  cover: carousel.cover,
                                ),
                              );
                            },
                            child: Image(
                              fit: BoxFit.cover,
                              image: CacheImage(carousel.cover),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                controller: _infiniteScrollController,
                itemExtent: 300.0,
                itemCount: carousels.length,
                center: false,
                velocityFactor: 0.8,
              ),
            ),
          );
        }
        return emptySliverToBoxAdapter;
      },
    );
  }

  Widget _buildOVA(ThemeData theme) {
    return Selector<IndexModel, List<RecordItem>>(
      selector: (_, model) => model.ovas,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, records, __) {
        if (records.isNullOrEmpty) {
          return emptySliverToBoxAdapter;
        }
        final simple = '🚀 ${records.length}条';
        final full = '更新${records.length}条记录';
        return MultiSliver(
          pushPinnedChildren: true,
          children: [
            SliverPinnedHeader(
              child: Container(
                padding: edgeH24V8,
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
                      child: Text(
                        simple,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: edgeH24B16T4,
              sliver: SliverWaterfallFlow(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final record = records[index];
                    return OVARecordItem(
                      index: index,
                      record: record,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.record.name,
                          arguments: Routes.record.d(url: record.url),
                        );
                      },
                    );
                  },
                  childCount: records.length,
                ),
                gridDelegate: SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
                  crossAxisSpacing: context.margins,
                  mainAxisSpacing: context.margins,
                  minCrossAxisExtent: 360.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

void showSearchPanel(BuildContext context) {
  Navigator.pushNamed(context, Routes.search.name);
}

void showSettingsPanel(BuildContext context) {
  MBottomSheet.show(
    context,
    (context) => const MBottomSheet(child: SettingsPanel()),
  );
}

void showYearSeasonBottomSheet(BuildContext context) {
  MBottomSheet.show(
    context,
    (context) => const MBottomSheet(child: SelectSeasonFragment()),
  );
}

class _PinedHeader extends StatelessWidget {
  const _PinedHeader();

  @override
  Widget build(BuildContext context) {
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
            onBuild: (
              BuildContext context,
              double shrinkOffset,
              bool overlapsContent,
            ) {
              final offsetRatio = math.min(shrinkOffset / offsetHeight, 1.0);
              final display = offsetRatio >= 0.8;
              final children = <Widget>[
                if (display)
                  RippleTap(
                    onTap: () {
                      showYearSeasonBottomSheet(context);
                    },
                    borderRadius: borderRadius28,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          Selector<IndexModel, Season?>(
                            selector: (_, model) => model.selectedSeason,
                            shouldRebuild: (pre, next) => pre != next,
                            builder: (_, season, __) {
                              return season == null
                                  ? sizedBox
                                  : Text(
                                      season.title,
                                      style: theme.textTheme.titleLarge,
                                    );
                            },
                          ),
                          sizedBoxW8,
                          const Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
              ];
              if (!isTablet) {
                children.add(
                  RippleTap(
                    onTap: () {
                      showSearchPanel(context);
                    },
                    shape: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.search_rounded),
                    ),
                  ),
                );
                children.add(buildAvatarWithAction(context));
              }
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
                          child: Selector<IndexModel, User?>(
                            selector: (_, model) => model.user,
                            shouldRebuild: (pre, next) => pre != next,
                            builder: (_, user, __) {
                              final withoutName =
                                  user == null || user.name.isNullOrBlank;
                              return Text(
                                withoutName
                                    ? 'Mikan Project'
                                    : 'Hi, ${user.name}',
                                style: theme.textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                        RippleTap(
                          onTap: () {
                            showYearSeasonBottomSheet(context);
                          },
                          borderRadius: borderRadius28,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              children: [
                                Selector<IndexModel, Season?>(
                                  selector: (_, model) => model.selectedSeason,
                                  shouldRebuild: (pre, next) => pre != next,
                                  builder: (_, season, __) {
                                    return season == null
                                        ? sizedBox
                                        : Text(
                                            season.title,
                                            style:
                                                theme.textTheme.headlineMedium,
                                          );
                                  },
                                ),
                                sizedBoxW8,
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
                        color: theme.colorScheme.background,
                        border: Border(
                          bottom: BorderSide(
                            color: display
                                ? theme.colorScheme.surfaceVariant
                                : Colors.transparent,
                          ),
                        ),
                      ),
                      padding: EdgeInsetsDirectional.only(
                        start: 12.0,
                        end: 12.0,
                        top: statusBarHeight,
                      ),
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
