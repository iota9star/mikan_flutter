import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../../features/bangumi/ui/bangumi.dart';
import '../../../features/home/providers/index_provider.dart';
import '../../../features/home/ui/fragments/index.dart' show showSettingsPanel;
import '../../../features/subscription/providers/subscribed_provider.dart';
import '../../../mikan_routes.dart';
import '../../../shared/internal/delegate.dart';
import '../../../shared/internal/extension.dart';
import '../../../shared/internal/image_provider.dart';
import '../../../shared/internal/kit.dart';
import '../../../topvars.dart';
import '../../models/bangumi.dart' as model;
import '../../models/record_item.dart';
import '../../models/season.dart';
import '../../models/season_gallery.dart';
import '../../models/year_season.dart';
import '../../widgets/scalable_tap.dart';
import '../../widgets/sliver_pinned_header.dart';
import '../../widgets/transition_container.dart';
import '../components/rss_record_item.dart';
import '../components/simple_record_item.dart' show currentRecordProvider;
import '../widgets/loading_widgets.dart';
import 'select_tablet_mode.dart';
import 'sliver_bangumi_list.dart';

@immutable
class SubscribedFragment extends ConsumerStatefulWidget {
  const SubscribedFragment({super.key});

  @override
  ConsumerState<SubscribedFragment> createState() => _SubscribedFragmentState();
}

class _SubscribedFragmentState extends ConsumerState<SubscribedFragment> with WidgetsBindingObserver {
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
        ref.invalidate(recentRecordsProvider);
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
    _timer = Timer.periodic(const Duration(milliseconds: 3600), (_) {
      if (_infiniteScrollController.hasClients) {
        _infiniteScrollController.animateToItem(
          (_infiniteScrollController.offset / 280.0).round() + 1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EasyRefresh.builder(
        onRefresh: () => ref.invalidate(recentRecordsProvider),
        refreshOnStart: true,
        header: defaultHeader,
        childBuilder: (context, physics) {
          return CustomScrollView(
            physics: physics,
            slivers: const [
              _PinedHeader(),
              _RssSlivers(),
              _SeasonSlivers(),
              _RecordsSlivers(),
              _SeeMoreButton(),
              _BottomPadding(),
            ],
          );
        },
      ),
    );
  }
}

class _PinedHeader extends ConsumerWidget {
  const _PinedHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rss = ref.watch(indexProvider.select((s) => s.value?.user?.rss));
    return TabletModeBuilder(
      builder: (context, isTablet, child) {
        return SliverPinnedAppBar(
          title: '我的订阅',
          autoImplLeading: false,
          actions: [
            if (rss.isNullOrBlank)
              const SizedBox.shrink()
            else
              IconButton(onPressed: rss.copy, icon: const Icon(Icons.rss_feed_rounded)),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.announcements.name);
              },
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            IconButton(
              onPressed: () {
                showSettingsPanel(context);
              },
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        );
      },
    );
  }
}

class _RssSlivers extends ConsumerWidget {
  const _RssSlivers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rss = ref.watch(rssRecordsProvider);
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        _RssSection(rss: rss),
        _RssList(rss: rss),
      ],
    );
  }
}

class _SeasonSlivers extends ConsumerWidget {
  const _SeasonSlivers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final years = ref.watch(yearsProvider);
    final season = ref.watch(selectedSeasonProvider);
    final bangumisAsync = ref.watch(subscribedBangumisProvider(season));
    return bangumisAsync.when(
      data: (bangumis) {
        return MultiSliver(
          pushPinnedChildren: true,
          children: [
            _SeasonRssSection(bangumis: bangumis, years: years, season: season),
            _SeasonRssList(bangumis: bangumis),
          ],
        );
      },
      loading: () => const SliverLoadingWidget(),
      error: (_, __) => const SliverEmptyWidget(text: '加载失败'),
    );
  }
}

class _RecordsSlivers extends ConsumerWidget {
  const _RecordsSlivers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recentRecordsProvider);
    return recordsAsync.when(
      data: (records) {
        return MultiSliver(
          pushPinnedChildren: true,
          children: [
            _RssRecordsSection(records: records),
            _RssRecordsList(records: records),
          ],
        );
      },
      loading: () => emptySliverToBoxAdapter,
      error: (_, __) => emptySliverToBoxAdapter,
    );
  }
}

/// RSS Section
class _RssSection extends ConsumerWidget {
  const _RssSection({required this.rss});

  final Map<String, List<RecordItem>> rss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isEmpty = rss.isNullOrEmpty;
    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsetsDirectional.only(start: 24.0, end: 12.0),
          height: 48.0,
          child: Row(
            children: [
              Expanded(child: Text('最近更新', style: theme.textTheme.titleMedium)),
              if (!isEmpty)
                Tooltip(
                  message: '最近三天共有${rss.length}部订阅更新',
                  child: Text('🚀 ${rss.length}部', style: theme.textTheme.bodySmall),
                ),
              const Gap(16),
              if (!isEmpty)
                IconButton(
                  onPressed: () {
                    final records = ref.read(recentRecordsProvider).value ?? [];
                    Navigator.pushNamed(
                      context,
                      Routes.subscribedRecent.name,
                      arguments: Routes.subscribedRecent.d(loaded: records),
                    );
                  },
                  icon: const Icon(Icons.east_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// RSS List
class _RssList extends ConsumerWidget {
  const _RssList({required this.rss});

  final Map<String, List<RecordItem>> rss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rss.isEmpty) {
      return const SliverEmptyWidget(text: '您的订阅中最近三天还没有更新内容哦\n快去添加订阅吧');
    }
    final entries = rss.entries.toList(growable: false);
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200.0,
        child: InfiniteCarousel.builder(
          itemCount: entries.length,
          itemExtent: 280.0,
          center: false,
          velocityFactor: 1.0,
          controller: InfiniteScrollController(),
          itemBuilder: (context, index, realIndex) {
            final entry = entries[index];
            return _RssListItem(entry: entry);
          },
        ),
      ),
    );
  }
}

/// RSS List Item
class _RssListItem extends StatelessWidget {
  const _RssListItem({required this.entry});

  final MapEntry<String, List<RecordItem>> entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final records = entry.value;
    final recordsLength = records.length;
    final record = records[0];
    final bangumiCover = record.cover;
    final bangumiId = entry.key;
    final badge = recordsLength > 99 ? '99+' : '+$recordsLength';
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 24.0, top: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TransitionContainer(
              next: BangumiPage(bangumiId: bangumiId, cover: bangumiCover, name: record.name),
              routeSettings: const RouteSettings(name: '/bangumi'),
              builder: (context, open) {
                return Stack(
                  children: [
                    ScalableCard(
                      onTap: open,
                      child: Tooltip(
                        message: records.first.name,
                        child: SizedBox.expand(
                          child: Image(
                            image: ResizeImage(
                              CacheImage(bangumiCover),
                              width: (280.0 * context.devicePixelRatio).ceil(),
                            ),
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
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      end: 12.0,
                      top: 12.0,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(color: theme.colorScheme.error, shape: const StadiumBorder()),
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        child: Text(
                          badge,
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onError),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Gap(10),
          Text(record.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
          if (record.publishAt.isNotBlank)
            Text(record.publishAt, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Season RSS Section
class _SeasonRssSection extends StatelessWidget {
  const _SeasonRssSection({required this.bangumis, required this.years, required this.season});

  final List<model.Bangumi>? bangumis;
  final List<YearSeason> years;
  final Season? season;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasVal = bangumis?.isNotEmpty ?? false;
    final updateNum = bangumis?.where((e) => e.num != null && e.num! > 0).length;
    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsetsDirectional.only(start: 24.0, end: 12.0),
          height: 48.0,
          child: Row(
            children: [
              Expanded(child: Text('季度订阅', style: theme.textTheme.titleMedium)),
              if (hasVal && updateNum != null && bangumis != null)
                Tooltip(
                  message: [if (updateNum > 0) '最近有更新 $updateNum部', '本季度共订阅 ${bangumis!.length}部'].join('，'),
                  child: Text(
                    [if (updateNum > 0) '🚀 $updateNum部', '🎬 ${bangumis!.length}部'].join('，'),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const Gap(16),
              if (hasVal && season != null)
                IconButton(
                  icon: const Icon(Icons.east_rounded),
                  onPressed: () {
                    final seasonValue = season!;
                    Navigator.pushNamed(
                      context,
                      Routes.subscribedSeason.name,
                      arguments: Routes.subscribedSeason.d(
                        years: years,
                        galleries: [
                          SeasonGallery(
                            year: seasonValue.year,
                            season: seasonValue.season,
                            title: seasonValue.title,
                            bangumis: bangumis ?? [],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Season RSS List
class _SeasonRssList extends ConsumerWidget {
  const _SeasonRssList({required this.bangumis});

  final List<model.Bangumi>? bangumis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bangumis == null) {
      return const SliverLoadingWidget();
    }
    if (bangumis!.isEmpty) {
      return const SliverEmptyWidget(text: '本季度您还没有订阅任何番组哦\n快去添加订阅吧');
    }
    return ProviderScope(
      overrides: [bangumisListProvider.overrideWithValue(bangumis!)],
      child: const SliverBangumiList(),
    );
  }
}

/// Records Section
class _RssRecordsSection extends ConsumerWidget {
  const _RssRecordsSection({required this.records});

  final List<RecordItem>? records;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (records.isNullOrEmpty) {
      return emptySliverToBoxAdapter;
    }
    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsetsDirectional.only(start: 24.0, end: 12.0),
          height: 48.0,
          child: Row(
            children: [
              Expanded(child: Text('更新列表', style: theme.textTheme.titleMedium)),
              IconButton(
                icon: const Icon(Icons.east_rounded),
                onPressed: () {
                  final records = ref.read(recentRecordsProvider).value ?? [];
                  Navigator.pushNamed(
                    context,
                    Routes.subscribedRecent.name,
                    arguments: Routes.subscribedRecent.d(loaded: records),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Records List
class _RssRecordsList extends StatelessWidget {
  const _RssRecordsList({required this.records});

  final List<RecordItem>? records;

  @override
  Widget build(BuildContext context) {
    if (records.isNullOrEmpty) {
      return emptySliverToBoxAdapter;
    }
    final margins = context.margins;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      sliver: SliverWaterfallFlow(
        gridDelegate: SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
          minCrossAxisExtent: 400.0,
          crossAxisSpacing: margins,
          mainAxisSpacing: margins,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final record = records![index];
          return ProviderScope(
            overrides: [currentRecordProvider.overrideWithValue(record)],
            child: const RssRecordItem(),
          );
        }, childCount: records!.length),
      ),
    );
  }
}

/// See More Button
class _SeeMoreButton extends ConsumerWidget {
  const _SeeMoreButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recentRecordsProvider);
    return recordsAsync.when(
      data: (records) {
        final length = records.length;
        if (length == 0) {
          return emptySliverToBoxAdapter;
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  final records = ref.read(recentRecordsProvider).value ?? [];
                  Navigator.pushNamed(
                    context,
                    Routes.subscribedRecent.name,
                    arguments: Routes.subscribedRecent.d(loaded: records),
                  );
                },
                child: const Text('查看更多'),
              ),
            ),
          ),
        );
      },
      loading: () => emptySliverToBoxAdapter,
      error: (_, __) => emptySliverToBoxAdapter,
    );
  }
}

/// Bottom Padding
class _BottomPadding extends StatelessWidget {
  const _BottomPadding();

  @override
  Widget build(BuildContext context) {
    return sliverGapH120WithNavBarHeight(context);
  }
}
