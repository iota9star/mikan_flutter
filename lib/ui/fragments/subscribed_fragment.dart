import 'dart:math' as Math;
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/season_gallery.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/view_models/subscribed_model.dart';
import 'package:mikan_flutter/ui/components/rss_record_item.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:mikan_flutter/widget/common_widgets.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@immutable
class SubscribedFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SubscribedModel subscribedModel =
        Provider.of<SubscribedModel>(context, listen: false);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: Scaffold(
        body: NotificationListener(
          onNotification: (notification) {
            if (notification is OverscrollIndicatorNotification) {
              notification.disallowGlow();
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
              backgroundColor: theme.accentColor,
              color: theme.accentColor.computeLuminance() < 0.5
                  ? Colors.white
                  : Colors.black,
              distance: Sz.statusBarHeight + 42.0,
            ),
            controller: subscribedModel.refreshController,
            enablePullDown: true,
            enablePullUp: false,
            onRefresh: subscribedModel.refresh,
            child: CustomScrollView(
              slivers: [
                _buildHeader(theme),
                _buildRssSection(context, theme, subscribedModel),
                _buildRssList(theme, subscribedModel),
                _buildSeasonRssSection(theme, subscribedModel),
                _buildSeasonRssList(theme, subscribedModel),
                _buildRssRecordsSection(context, theme),
                _buildRssRecordsList(theme),
                CommonWidgets.sliverBottomSpace,
              ],
            ),
          ),
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
              boxShadow: hasScrolled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.024),
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        spreadRadius: 3.0,
                      ),
                    ]
                  : null,
              borderRadius: hasScrolled
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    )
                  : null,
            ),
            padding: EdgeInsets.only(
              top: 16.0 + Sz.statusBarHeight,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            duration: Duration(milliseconds: 240),
            child: Row(
              children: <Widget>[
                Text(
                  "我的订阅",
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
              margin: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 8.0,
                top: 8.0,
              ),
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: 24.0,
                top: 24.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    theme.backgroundColor.withOpacity(0.72),
                    theme.backgroundColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Center(child: CupertinoActivityIndicator()),
            ),
          );
        }
        if (bangumis.isNullOrEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              height: 240.0,
              margin: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 8.0,
                top: 8.0,
              ),
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: 24.0,
                top: 24.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    theme.backgroundColor.withOpacity(0.72),
                    theme.backgroundColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Center(child: Text(">_< 您还没有订阅任何番组，快去添加订阅吧")),
            ),
          );
        }
        return BangumiSliverGridFragment(
          flag: "subscribed",
          bangumis: bangumis!,
          handleSubscribe: (bangumi, flag) {
            context.read<SubscribedModel>().subscribeBangumi(
              bangumi.id,
              bangumi.subscribed,
              onSuccess: () {
                bangumi.subscribed = !bangumi.subscribed;
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 24.0,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "季度订阅",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
            ),
            Selector<SubscribedModel, List<YearSeason>?>(
              selector: (_, model) => model.years,
              shouldRebuild: (pre, next) => pre.ne(next),
              builder: (context, years, __) {
                if (years.isNullOrEmpty) return SizedBox();
                return MaterialButton(
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
                  minWidth: 0,
                  padding: EdgeInsets.all(5.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: CircleBorder(),
                  child: Icon(
                    FluentIcons.chevron_right_24_regular,
                    size: 16.0,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRssSection(
    final BuildContext context,
    final ThemeData theme,
    final SubscribedModel subscribedModel,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: 8.0,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "最近更新",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                _toRecentSubscribedPage(context);
              },
              color: theme.backgroundColor,
              minWidth: 0,
              padding: EdgeInsets.all(5.0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: CircleBorder(),
              child: Icon(
                FluentIcons.chevron_right_24_regular,
                size: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRssList(
    final ThemeData theme,
    final SubscribedModel subscribedModel,
  ) {
    return SliverToBoxAdapter(
      child: Selector<SubscribedModel, Map<String, List<RecordItem>>?>(
        selector: (_, model) => model.rss,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, rss, __) {
          if (subscribedModel.recordsLoading) {
            return Container(
              width: double.infinity,
              height: 120.0,
              margin: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 8.0,
                top: 8.0,
              ),
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: 24.0,
                top: 24.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    theme.backgroundColor.withOpacity(0.72),
                    theme.backgroundColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Center(child: CupertinoActivityIndicator()),
            );
          }
          if (rss.isSafeNotEmpty)
            return SizedBox(
              height: 64.0 + 16.0,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                itemBuilder: (context, index) {
                  final entry = rss!.entries.elementAt(index);
                  return _buildRssListItemCover(context, entry);
                },
                itemCount: rss!.length,
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
              ),
            );
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 8.0,
              top: 8.0,
            ),
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              bottom: 24.0,
              top: 24.0,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  theme.backgroundColor.withOpacity(0.72),
                  theme.backgroundColor.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(child: Text(">_< 您还没有订阅任何番组，快去添加订阅吧")),
          );
        },
      ),
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
    return TapScaleContainer(
      width: 64.0,
      margin: EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 8.0,
      ),
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
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          fit: StackFit.loose,
          clipBehavior: Clip.antiAlias,
          children: [
            Positioned.fill(
              child: Hero(
                tag: currFlag,
                child: ExtendedImage(
                  image: ExtendedNetworkImageProvider(bangumiCover),
                  fit: BoxFit.cover,
                  loadStateChanged: (state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                        return Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: ExtendedImage.asset(
                              "assets/mikan.png",
                            ),
                          ),
                        );
                      case LoadState.failed:
                        return Padding(
                          padding: EdgeInsets.all(16.0),
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
                angle: Math.pi / 4.0,
                child: Container(
                  width: 42.0,
                  color: Colors.redAccent,
                  child: Text(
                    badge,
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
        if (records.isNullOrEmpty) return SliverToBoxAdapter();
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "更新列表",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    _toRecentSubscribedPage(context);
                  },
                  color: theme.backgroundColor,
                  minWidth: 0,
                  padding: EdgeInsets.all(5.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: CircleBorder(),
                  child: Icon(
                    FluentIcons.chevron_right_24_regular,
                    size: 16.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRssRecordsList(final ThemeData theme) {
    return Selector<SubscribedModel, List<RecordItem>?>(
      selector: (_, model) => model.records,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, records, __) {
        if (records.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        final int length = records!.length;
        return SliverPadding(
          padding: EdgeInsets.only(
            bottom: 8.0,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: TextButton(
                      onPressed: () {
                        _toRecentSubscribedPage(context);
                      },
                      child: Text("没有找到您需要的？点击查看更多"),
                    ),
                  );
                }
                final RecordItem record = records[index];
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
              childCount: length > 10 ? length + 1 : length,
            ),
          ),
        );
      },
    );
  }
}
