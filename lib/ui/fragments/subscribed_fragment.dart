import 'dart:math' as math;

import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/season_gallery.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/providers/op_model.dart';
import 'package:mikan_flutter/providers/subscribed_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/components/rss_record_item.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliver_tools/sliver_tools.dart';

@immutable
class SubscribedFragment extends StatelessWidget {
  const SubscribedFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: Scaffold(
        body: Selector<IndexModel, User?>(
          builder: (BuildContext context, User? value, Widget? child) {
            return value?.name?.isNotBlank == true
                ? _buildSubscribedView(context, theme)
                : _buildLoginView(context, theme);
          },
          selector: (_, model) => model.user,
        ),
      ),
    );
  }

  Widget _buildLoginView(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: scrollHeaderBorderRadius(true),
            boxShadow: scrollHeaderBoxShadow(true),
          ),
          width: double.infinity,
          padding: edge16WithStatusBar,
          child: const Text(
            "我的订阅",
            style: textStyle24B,
          ),
        ),
        Expanded(
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.login.name);
              },
              child: const Text("您还没有登录，请先登录"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribedView(
    BuildContext context,
    ThemeData theme,
  ) {
    final subscribedModel =
        Provider.of<SubscribedModel>(context, listen: false);
    return NotificationListener(
      onNotification: (notification) {
        if (notification is OverscrollIndicatorNotification) {
          notification.disallowIndicator();
        } else if (notification is ScrollUpdateNotification) {
          if (notification.depth == 0) {
            final double offset = notification.metrics.pixels;
            subscribedModel.hasScrolled = offset > 0.0;
          }
        }
        return true;
      },
      child: SmartRefresher(
        header: WaterDropMaterialHeader(
          backgroundColor: theme.secondary,
          color: theme.secondary.isDark ? Colors.white : Colors.black,
          distance: Screen.statusBarHeight + 42.0,
        ),
        controller: subscribedModel.refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: subscribedModel.refresh,
        child: CustomScrollView(
          slivers: [
            _buildHeader(theme),
            MultiSliver(
              pushPinnedChildren: true,
              children: [
                _buildRssSection(context, theme),
                _buildRssList(theme, subscribedModel),
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
                _buildRssRecordsList(theme),
              ],
            ),
            _buildSeeMore(theme, subscribedModel),
            sliverSizedBoxH80,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(final ThemeData theme) {
    return Selector<SubscribedModel, bool>(
      selector: (_, model) => model.hasScrolled,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, hasScrolled, __) {
        return SliverPinnedToBoxAdapter(
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: hasScrolled
                  ? theme.backgroundColor
                  : theme.scaffoldBackgroundColor,
              borderRadius: scrollHeaderBorderRadius(hasScrolled),
              boxShadow: scrollHeaderBoxShadow(hasScrolled),
            ),
            padding: edge16WithStatusBar,
            duration: dur240,
            child: const Text(
              "我的订阅",
              style: textStyle24B,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeasonRssList(
    final ThemeData theme,
    final SubscribedModel subscribedModel,
  ) {
    return Selector<SubscribedModel, List<Bangumi>?>(
      selector: (_, model) => model.bangumis,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, bangumis, __) {
        if (subscribedModel.seasonLoading) {
          return SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              height: 240.0,
              margin: edgeH16V8,
              padding: edge24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    theme.backgroundColor.withOpacity(0.72),
                    theme.backgroundColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: borderRadius16,
              ),
              child: centerLoading,
            ),
          );
        }
        if (bangumis.isNullOrEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              margin: edgeH16V8,
              padding: edge28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    theme.backgroundColor.withOpacity(0.72),
                    theme.backgroundColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: borderRadius16,
              ),
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/mikan.png",
                      width: 64.0,
                    ),
                    sizedBoxH12,
                    const Text(
                      "本季度您还没有订阅任何番组哦\n快去添加订阅吧",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return BangumiSliverGridFragment(
          flag: "subscribed",
          bangumis: bangumis!,
          padding: edgeH16V8,
          handleSubscribe: (bangumi, flag) {
            context.read<OpModel>().subscribeBangumi(
              bangumi.id,
              bangumi.subscribed,
              onSuccess: () {
                bangumi.subscribed = !bangumi.subscribed;
                context.read<OpModel>().subscribeChanged(flag);
              },
              onError: (msg) {
                "订阅失败：$msg".toast();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSeasonRssSection(
    final ThemeData theme,
    final SubscribedModel subscribedModel,
  ) {
    return SliverPinnedToBoxAdapter(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: edgeH16V8,
          child: Selector<SubscribedModel, List<Bangumi>?>(
              selector: (_, model) => model.bangumis,
              builder: (context, bangumis, _) {
                final hasVal = bangumis.isSafeNotEmpty;
                final updateNum =
                    bangumis?.where((e) => e.num != null && e.num! > 0).length;
                return Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "季度订阅",
                        style: textStyle20B,
                      ),
                    ),
                    if (hasVal)
                      Tooltip(
                        message: [
                          if (updateNum! > 0) "最近有更新 $updateNum部",
                          "本季度共订阅 ${bangumis!.length}部"
                        ].join("，"),
                        child: Text(
                          [
                            if (updateNum > 0) "🚀 $updateNum部",
                            "🎬 ${bangumis.length}部"
                          ].join("，"),
                          style: TextStyle(
                            color: theme.textTheme.subtitle1?.color,
                            fontSize: 14.0,
                            height: 1.25,
                          ),
                        ),
                      ),
                    sizedBoxW16,
                    if (hasVal)
                      MaterialButton(
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
                        color: theme.backgroundColor,
                        minWidth: 32.0,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: circleShape,
                        child: const Icon(
                          FluentIcons.chevron_right_24_regular,
                          size: 16.0,
                        ),
                      ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget _buildRssSection(
    final BuildContext context,
    final ThemeData theme,
  ) {
    return SliverPinnedToBoxAdapter(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: edgeH16V8,
          child: Selector<SubscribedModel, Map<String, List<RecordItem>>?>(
              selector: (_, model) => model.rss,
              builder: (context, rss, child) {
                final isEmpty = rss.isNullOrEmpty;
                return Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "最近更新",
                        style: textStyle20B,
                      ),
                    ),
                    if (!isEmpty)
                      Tooltip(
                        message: "最近三天共有${rss!.length}部订阅更新",
                        child: Text(
                          "🚀 ${rss.length}部",
                          style: TextStyle(
                            color: theme.textTheme.subtitle1?.color,
                            fontSize: 14.0,
                            height: 1.25,
                          ),
                        ),
                      ),
                    sizedBoxW16,
                    if (!isEmpty)
                      MaterialButton(
                        onPressed: () {
                          _toRecentSubscribedPage(context);
                        },
                        color: theme.backgroundColor,
                        minWidth: 32.0,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: circleShape,
                        child: const Icon(
                          FluentIcons.chevron_right_24_regular,
                          size: 16.0,
                        ),
                      ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget _buildRssList(
    final ThemeData theme,
    final SubscribedModel subscribedModel,
  ) {
    return Selector<SubscribedModel, Map<String, List<RecordItem>>?>(
      selector: (_, model) => model.rss,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, rss, __) {
        if (subscribedModel.recordsLoading) {
          return SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              height: 120.0,
              margin: edgeH16V8,
              padding: edge24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    theme.backgroundColor.withOpacity(0.72),
                    theme.backgroundColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: borderRadius16,
              ),
              child: centerLoading,
            ),
          );
        }
        if (rss.isSafeNotEmpty) {
          return SliverPadding(
            padding: edgeH16V8,
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 108.0,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = rss!.entries.elementAt(index);
                  return _buildRssListItemCover(context, entry);
                },
                childCount: rss!.length,
              ),
            ),
          );
        }
        return SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            margin: edgeH16V8,
            padding: edge24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  theme.backgroundColor.withOpacity(0.72),
                  theme.backgroundColor.withOpacity(0.9),
                ],
              ),
              borderRadius: borderRadius16,
            ),
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                    "assets/mikan.png",
                    width: 64.0,
                  ),
                  sizedBoxH12,
                  const Text(
                    "您的订阅中最近三天还没有更新内容哦\n快去添加订阅吧",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toRecentSubscribedPage(final BuildContext context) {
    Navigator.pushNamed(
      context,
      Routes.recentSubscribed.name,
      arguments: Routes.recentSubscribed
          .d(loaded: context.read<SubscribedModel>().records ?? []),
    );
  }

  Widget _buildRssListItemCover(
    final BuildContext context,
    final MapEntry<String, List<RecordItem>> entry,
  ) {
    final List<RecordItem> records = entry.value;
    final int recordsLength = records.length;
    final String bangumiCover = records[0].cover;
    final String bangumiId = entry.key;
    final String badge = recordsLength > 99 ? "99+" : "+$recordsLength";
    final String currFlag = "rss:$bangumiId:$bangumiCover";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TapScaleContainer(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withOpacity(0.08),
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.bangumi.name,
                arguments: Routes.bangumi.d(
                  heroTag: currFlag,
                  bangumiId: bangumiId,
                  cover: bangumiCover,
                ),
              );
            },
            child: ClipRRect(
              borderRadius: borderRadius8,
              child: Stack(
                fit: StackFit.loose,
                clipBehavior: Clip.antiAlias,
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: currFlag,
                      child: ExtendedImage(
                        image: FastCacheImage(bangumiCover),
                        fit: BoxFit.cover,
                        loadStateChanged: (state) {
                          switch (state.extendedImageLoadState) {
                            case LoadState.loading:
                              return Padding(
                                padding: edge16,
                                child: Center(
                                  child: ExtendedImage.asset(
                                    "assets/mikan.png",
                                  ),
                                ),
                              );
                            case LoadState.failed:
                              return Padding(
                                padding: edge16,
                                child: Center(
                                  child: ExtendedImage.asset(
                                    "assets/mikan.png",
                                    colorBlendMode: BlendMode.color,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            case LoadState.completed:
                              return null;
                          }
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: -10,
                    top: 4,
                    child: Transform.rotate(
                      angle: math.pi / 4.0,
                      child: Container(
                        width: 42.0,
                        color: Colors.redAccent,
                        child: Text(
                          badge,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            wordSpacing: 1.0,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        sizedBoxH8,
        Tooltip(
          message: records.first.name,
          child: Text(
            records.first.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle15B500,
          ),
        )
      ],
    );
  }

  Widget _buildRssRecordsSection(
    final BuildContext context,
    final ThemeData theme,
  ) {
    return Selector<SubscribedModel, List<RecordItem>?>(
      selector: (_, model) => model.records,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, records, __) {
        if (records.isNullOrEmpty) return emptySliverToBoxAdapter;
        return SliverPinnedToBoxAdapter(
          child: Transform.translate(
            offset: offsetY_1,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              padding: edgeH16V8,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "更新列表",
                      style: textStyle20B,
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      _toRecentSubscribedPage(context);
                    },
                    color: theme.backgroundColor,
                    minWidth: 32.0,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: circleShape,
                    child: const Icon(
                      FluentIcons.chevron_right_24_regular,
                      size: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRssRecordsList(final ThemeData theme) {
    return SliverPadding(
      padding: edgeH16V8,
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
                final RecordItem record = records![index];
                return RssRecordItem(
                  index: index,
                  record: record,
                  theme: theme,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.recordDetail.name,
                      arguments: Routes.recordDetail.d(url: record.url),
                    );
                  },
                );
              },
              childCount: records!.length,
            ),
            gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              mainAxisExtent: 170.0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeeMore(
    final ThemeData theme,
    final SubscribedModel subscribedModel,
  ) {
    return Selector<SubscribedModel, int>(
      builder: (context, length, _) {
        if (length == 0) {
          return emptySliverToBoxAdapter;
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: edge16,
            child: TextButton(
              onPressed: () {
                _toRecentSubscribedPage(context);
              },
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  color: theme.secondary,
                ),
                shadowColor: theme.secondary.withOpacity(0.87),
              ),
              child: const Text("查看更多"),
            ),
          ),
        );
      },
      shouldRebuild: (pre, next) => pre != next,
      selector: (_, model) => model.records?.length ?? 0,
    );
  }
}
