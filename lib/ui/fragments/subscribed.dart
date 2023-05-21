import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../internal/extension.dart';
import '../../internal/image_provider.dart';
import '../../internal/kit.dart';
import '../../mikan_routes.dart';
import '../../model/bangumi.dart';
import '../../model/record_item.dart';
import '../../model/season_gallery.dart';
import '../../providers/op_model.dart';
import '../../providers/subscribed_model.dart';
import '../../topvars.dart';
import '../../widget/scalable_tap.dart';
import '../../widget/sliver_pinned_header.dart';
import '../components/rss_record_item.dart';
import 'bangumi_sliver_grid.dart';
import 'index.dart';
import 'select_tablet_mode.dart';

@immutable
class SubscribedFragment extends StatelessWidget {
  const SubscribedFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: Scaffold(
        body: _buildSubscribedView(context, theme),
      ),
    );
  }

  Widget _buildSubscribedView(
    BuildContext context,
    ThemeData theme,
  ) {
    final subscribedModel =
        Provider.of<SubscribedModel>(context, listen: false);
    return EasyRefresh(
      onRefresh: subscribedModel.refresh,
      refreshOnStart: true,
      header: defaultHeader,
      footer: defaultFooter(context),
      child: CustomScrollView(
        slivers: [
          const _PinedHeader(),
          MultiSliver(
            pushPinnedChildren: true,
            children: [
              _buildRssSection(context, theme),
              _buildRssList(context, theme, subscribedModel),
            ],
          ),
          MultiSliver(
            pushPinnedChildren: true,
            children: [
              _buildSeasonRssSection(theme, subscribedModel),
              _buildSeasonRssList(theme, subscribedModel),
            ],
          ),
          MultiSliver(
            pushPinnedChildren: true,
            children: [
              _buildRssRecordsSection(context, theme),
              _buildRssRecordsList(context, theme),
            ],
          ),
          _buildSeeMore(theme, subscribedModel),
          sliverSizedBoxH80WithNavBarHeight(context),
        ],
      ),
    );
  }

  Widget _buildSeasonRssList(
    ThemeData theme,
    SubscribedModel subscribedModel,
  ) {
    return Selector<SubscribedModel, List<Bangumi>?>(
      selector: (_, model) => model.bangumis,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, bangumis, __) {
        if (subscribedModel.seasonLoading) {
          return _buildLoading();
        }
        if (bangumis.isNullOrEmpty) {
          return _buildEmpty(
            theme,
            '本季度您还没有订阅任何番组哦\n快去添加订阅吧',
          );
        }
        return BangumiSliverGridFragment(
          flag: 'subscribed',
          bangumis: bangumis!,
          handleSubscribe: (bangumi, flag) {
            context.read<OpModel>().subscribeBangumi(
              bangumi.id,
              bangumi.subscribed,
              onSuccess: () {
                bangumi.subscribed = !bangumi.subscribed;
                context.read<OpModel>().subscribeChanged(flag);
              },
              onError: (msg) {
                '订阅失败：$msg'.toast();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSeasonRssSection(
    ThemeData theme,
    SubscribedModel subscribedModel,
  ) {
    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: edgeS24E12,
          height: 48.0,
          child: Selector<SubscribedModel, List<Bangumi>?>(
            selector: (_, model) => model.bangumis,
            builder: (context, bangumis, _) {
              final hasVal = bangumis.isSafeNotEmpty;
              final updateNum =
                  bangumis?.where((e) => e.num != null && e.num! > 0).length;
              return Row(
                children: [
                  Expanded(
                    child: Text('季度订阅', style: theme.textTheme.titleMedium),
                  ),
                  if (hasVal)
                    Tooltip(
                      message: [
                        if (updateNum! > 0) '最近有更新 $updateNum部',
                        '本季度共订阅 ${bangumis!.length}部'
                      ].join('，'),
                      child: Text(
                        [
                          if (updateNum > 0) '🚀 $updateNum部',
                          '🎬 ${bangumis.length}部'
                        ].join('，'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  sizedBoxW16,
                  if (hasVal)
                    IconButton(
                      icon: const Icon(Icons.east_rounded),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Routes.subscribedSeason.name,
                          arguments: Routes.subscribedSeason.d(
                            years: subscribedModel.years ?? [],
                            galleries: [
                              SeasonGallery(
                                year: subscribedModel.season!.year,
                                season: subscribedModel.season!.season,
                                title: subscribedModel.season!.title,
                                bangumis: subscribedModel.bangumis ?? [],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRssSection(
    BuildContext context,
    ThemeData theme,
  ) {
    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: edgeS24E12,
          height: 48.0,
          child: Selector<SubscribedModel, Map<String, List<RecordItem>>?>(
            selector: (_, model) => model.rss,
            builder: (context, rss, child) {
              final isEmpty = rss.isNullOrEmpty;
              return Row(
                children: [
                  Expanded(
                    child: Text('最近更新', style: theme.textTheme.titleMedium),
                  ),
                  if (!isEmpty)
                    Tooltip(
                      message: '最近三天共有${rss!.length}部订阅更新',
                      child: Text(
                        '🚀 ${rss.length}部',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  sizedBoxW16,
                  if (!isEmpty)
                    IconButton(
                      onPressed: () {
                        _toRecentSubscribedPage(context);
                      },
                      icon: const Icon(Icons.east_rounded),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRssList(
    BuildContext context,
    ThemeData theme,
    SubscribedModel subscribedModel,
  ) {
    return Selector<SubscribedModel, Map<String, List<RecordItem>>?>(
      selector: (_, model) => model.rss,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, rss, __) {
        if (subscribedModel.recordsLoading) {
          return _buildLoading();
        }
        if (rss.isNullOrEmpty) {
          return _buildEmpty(
            theme,
            '您的订阅中最近三天还没有更新内容哦\n快去添加订阅吧',
          );
        }
        final entries = rss!.entries.toList(growable: false);
        return SliverPadding(
          padding: edgeH24V8,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200.0,
              crossAxisSpacing: context.margins,
              mainAxisSpacing: context.margins,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildRssListItem(context, theme, entries[index]);
              },
              childCount: entries.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(ThemeData theme, String text) {
    return SliverToBoxAdapter(
      child: Container(
        margin: edgeH24B16,
        child: ScalableCard(
          onTap: () {},
          child: Padding(
            padding: edge24,
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/mikan.png',
                    width: 64.0,
                  ),
                  sizedBoxH12,
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return SliverToBoxAdapter(
      child: Container(
        height: 180.0,
        margin: edgeH24B16,
        child: SizedBox.expand(
          child: ScalableCard(onTap: () {}, child: centerLoading),
        ),
      ),
    );
  }

  void _toRecentSubscribedPage(BuildContext context) {
    Navigator.pushNamed(
      context,
      Routes.subscribedRecent.name,
      arguments: Routes.subscribedRecent
          .d(loaded: context.read<SubscribedModel>().records ?? []),
    );
  }

  Widget _buildRssListItem(
    BuildContext context,
    ThemeData theme,
    MapEntry<String, List<RecordItem>> entry,
  ) {
    final List<RecordItem> records = entry.value;
    final int recordsLength = records.length;
    final record = records[0];
    final String bangumiCover = record.cover;
    final String bangumiId = entry.key;
    final String badge = recordsLength > 99 ? '99+' : '+$recordsLength';
    final String currFlag = 'rss:$bangumiId:$bangumiCover';
    final imageProvider = CacheImage(bangumiCover);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: ScalableCard(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.bangumi.name,
                      arguments: Routes.bangumi.d(
                        heroTag: currFlag,
                        bangumiId: bangumiId,
                        cover: bangumiCover,
                        title: record.name,
                      ),
                    );
                  },
                  child: Hero(
                    tag: currFlag,
                    child: Tooltip(
                      message: records.first.name,
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, event) {
                          return event == null
                              ? child
                              : Padding(
                                  padding: edge16,
                                  child: Center(
                                    child: Image.asset(
                                      'assets/mikan.png',
                                    ),
                                  ),
                                );
                        },
                        errorBuilder: (_, __, ___) {
                          return Padding(
                            padding: edge16,
                            child: Center(
                              child: Image.asset(
                                'assets/mikan.png',
                                colorBlendMode: BlendMode.color,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 12.0,
                end: 12.0,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: theme.colorScheme.error,
                    shape: const StadiumBorder(),
                  ),
                  padding: edgeH6V2,
                  child: Text(
                    badge,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onError,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        sizedBoxH8,
        Text(
          record.name,
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          record.publishAt,
          style: theme.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRssRecordsSection(
    BuildContext context,
    ThemeData theme,
  ) {
    return Selector<SubscribedModel, List<RecordItem>?>(
      selector: (_, model) => model.records,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, records, __) {
        if (records.isNullOrEmpty) {
          return emptySliverToBoxAdapter;
        }
        return SliverPinnedHeader(
          child: Transform.translate(
            offset: offsetY_1,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              padding: edgeS24E12,
              height: 48.0,
              child: Row(
                children: [
                  Expanded(
                    child: Text('更新列表', style: theme.textTheme.titleMedium),
                  ),
                  IconButton(
                    icon: const Icon(Icons.east_rounded),
                    onPressed: () {
                      _toRecentSubscribedPage(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRssRecordsList(BuildContext context, ThemeData theme) {
    return SliverPadding(
      padding: edgeH24V8,
      sliver: Selector<SubscribedModel, List<RecordItem>?>(
        selector: (_, model) => model.records,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, records, __) {
          if (records.isNullOrEmpty) {
            return emptySliverToBoxAdapter;
          }
          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final record = records[index];
                return RssRecordItem(
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
              childCount: records!.length,
            ),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400.0,
              crossAxisSpacing: context.margins,
              mainAxisSpacing: context.margins,
              mainAxisExtent: 164.0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeeMore(
    ThemeData theme,
    SubscribedModel subscribedModel,
  ) {
    return Selector<SubscribedModel, int>(
      builder: (context, length, _) {
        if (length == 0) {
          return emptySliverToBoxAdapter;
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: edge24,
            child: ElevatedButton(
              onPressed: () {
                _toRecentSubscribedPage(context);
              },
              child: const Text('查看更多'),
            ),
          ),
        );
      },
      shouldRebuild: (pre, next) => pre != next,
      selector: (_, model) => model.records?.length ?? 0,
    );
  }
}

class _PinedHeader extends StatelessWidget {
  const _PinedHeader();

  @override
  Widget build(BuildContext context) {
    return TabletModeBuilder(
      builder: (context, isTablet, child) {
        return SliverPinnedAppBar(
          title: '我的订阅',
          autoImplLeading: false,
          actions: isTablet
              ? null
              : [
                  IconButton(
                    onPressed: () {
                      showSettingsPanel(context);
                    },
                    icon: const Icon(Icons.tune_rounded),
                  )
                ],
        );
      },
    );
  }
}
