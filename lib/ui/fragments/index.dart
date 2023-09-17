import 'dart:async';
import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../internal/extension.dart';
import '../../internal/image_provider.dart';
import '../../internal/kit.dart';
import '../../internal/lifecycle.dart';
import '../../model/bangumi_row.dart';
import '../../model/carousel.dart';
import '../../model/record_item.dart';
import '../../model/season.dart';
import '../../model/user.dart';
import '../../providers/index_model.dart';
import '../../providers/op_model.dart';
import '../../topvars.dart';
import '../../widget/bottom_sheet.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/sliver_pinned_header.dart';
import '../../widget/transition_container.dart';
import '../components/simple_record_item.dart';
import '../pages/bangumi.dart';
import '../pages/search.dart';
import 'select_season.dart';
import 'select_tablet_mode.dart';
import 'settings.dart';
import 'sliver_bangumi_list.dart';

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
    _newTimer();
  }

  @override
  void onPause() {
    _timer?.cancel();
  }

  @override
  void onResume() {
    _newTimer();
  }

  void _newTimer() {
    _timer?.cancel();
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
                          SliverBangumiList(
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
      '🎬 ${bangumiRow.num}部',
    ].join('，');
    final full = [
      if (bangumiRow.updatedNum > 0) '更新${bangumiRow.updatedNum}部',
      if (bangumiRow.subscribedUpdatedNum > 0)
        '订阅更新${bangumiRow.subscribedUpdatedNum}部',
      if (bangumiRow.subscribedNum > 0) '订阅${bangumiRow.subscribedNum}部',
      '共${bangumiRow.num}部',
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
              height: 160.0,
              child: InfiniteCarousel.builder(
                itemBuilder: (context, index, realIndex) {
                  final carousel = carousels[index];
                  final currentOffset = 300.0 * realIndex;
                  return AnimatedBuilder(
                    animation: _infiniteScrollController,
                    builder: (_, __) {
                      final diff =
                          _infiniteScrollController.offset - currentOffset;
                      final ver = (diff / 36.0).abs();
                      return Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 24.0,
                          top: (ver > 12.0 ? 12.0 : ver) + 8,
                          bottom: 8.0,
                        ),
                        child: TransitionContainer(
                          builder: (context, open) {
                            return RippleTap(
                              onTap: open,
                              child: Image(
                                fit: BoxFit.cover,
                                image: CacheImage(carousel.cover),
                              ),
                            );
                          },
                          next: BangumiPage(
                            bangumiId: carousel.id,
                            cover: carousel.cover,
                          ),
                        ),
                      );
                    },
                  );
                },
                controller: _infiniteScrollController,
                itemExtent: 300.0,
                itemCount: carousels.length,
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
        final margins = context.margins;
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
                gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                  crossAxisSpacing: margins,
                  mainAxisSpacing: margins,
                  maxCrossAxisExtent: 400.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final record = records[index];
                    return SimpleRecordItem(record: record);
                  },
                  childCount: records.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
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
                  TransitionContainer(
                    next: const SearchPage(),
                    builder: (context, open) {
                      return RippleTap(
                        onTap: open,
                        shape: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.search_rounded),
                        ),
                      );
                    },
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
