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
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/providers/models/subscribed_model.dart';
import 'package:mikan_flutter/ui/components/rss_record_item.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@immutable
class SubscribedFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).accentColor;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentTextColor =
        accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
    final TextStyle fileTagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: accentTextColor,
    );
    final TextStyle titleTagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color:
          primaryColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    final Color backgroundColor = Theme.of(context).backgroundColor;
    final Color scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;
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
              backgroundColor: accentColor,
              color: accentTextColor,
              distance: Sz.statusBarHeight + 12.0,
            ),
            controller: subscribedModel.refreshController,
            enablePullDown: true,
            enablePullUp: false,
            onRefresh: subscribedModel.refresh,
            child: CustomScrollView(
              slivers: [
                _buildHeader(backgroundColor, scaffoldBackgroundColor),
                _buildRssSection(),
                _buildRssList(backgroundColor),
                _buildSeasonRssSection(
                    context, backgroundColor, subscribedModel),
                _buildSeasonRssList(backgroundColor, subscribedModel),
                _buildRssRecordsSection(),
                _buildRssRecordsList(
                  accentColor,
                  primaryColor,
                  backgroundColor,
                  fileTagStyle,
                  titleTagStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    final Color backgroundColor,
    final Color scaffoldBackgroundColor,
  ) {
    return Selector<SubscribedModel, bool>(
      selector: (_, model) => model.hasScrolled,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, hasScrolled, __) {
        return SliverPinnedToBoxAdapter(
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: hasScrolled ? backgroundColor : scaffoldBackgroundColor,
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
    final Color backgroundColor,
    final SubscribedModel subscribedModel,
  ) {
    return Selector<SubscribedModel, List<Bangumi>>(
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
                    backgroundColor.withOpacity(0.72),
                    backgroundColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
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
                    backgroundColor.withOpacity(0.72),
                    backgroundColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              child: Center(child: Text(">_< 您还没有订阅任何番组，快去添加订阅吧")),
            ),
          );
        }
        return BangumiSliverGridFragment(
          flag: "subscribed",
          bangumis: bangumis,
        );
      },
    );
  }

  Widget _buildSeasonRssSection(
    final BuildContext context,
    final Color backgroundColor,
    final SubscribedModel subscribedModel,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 8.0,
          top: 16.0,
          bottom: 8.0,
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
            Selector<SubscribedModel, List<YearSeason>>(
              selector: (_, model) => model.years,
              shouldRebuild: (pre, next) => pre.ne(next),
              builder: (_, years, __) {
                if (years.isNullOrEmpty) return Container();
                return MaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.subscribedSeason.name,
                      arguments: Routes.subscribedSeason.d(
                        years: subscribedModel.years,
                        galleries: [
                          SeasonGallery(
                            season: subscribedModel.season.title,
                            bangumis: subscribedModel.bangumis,
                          )
                        ],
                      ),
                    );
                  },
                  color: backgroundColor,
                  minWidth: 0,
                  padding: EdgeInsets.all(5.0),
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

  Widget _buildRssSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: 8.0,
        ),
        child: Text(
          "最近更新",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
        ),
      ),
    );
  }

  Widget _buildRssList(final Color backgroundColor) {
    return SliverToBoxAdapter(
      child: Selector<SubscribedModel, Map<String, List<RecordItem>>>(
        selector: (_, model) => model.rss,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, rss, __) {
          if (rss.isSafeNotEmpty)
            return SizedBox(
              height: 64.0 + 24.0,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildMoreRssItemBtn(context, rss);
                  }
                  final entry = rss.entries.elementAt(index - 1);
                  return _buildRssListItemCover(entry);
                },
                itemCount: rss.length + 1,
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
                  backgroundColor.withOpacity(0.72),
                  backgroundColor.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            child: Center(child: Text(">_< 您还没有订阅任何番组，快去添加订阅吧")),
          );
        },
      ),
    );
  }

  Widget _buildMoreRssItemBtn(
    final BuildContext context,
    final Map<String, List<RecordItem>> rss,
  ) {
    return Selector<IndexModel, String>(
      selector: (_, model) => model.tapBangumiRssItemFlag,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, tapScaleFlag, child) {
        final String currFlag = "rss:more-rss";
        final Matrix4 transform = tapScaleFlag == currFlag
            ? Matrix4.diagonal3Values(0.9, 0.9, 1)
            : Matrix4.identity();
        return AnimatedTapContainer(
          transform: transform,
          onTapStart: () =>
              context.read<IndexModel>().tapBangumiRssItemFlag = currFlag,
          onTapEnd: () =>
              context.read<IndexModel>().tapBangumiRssItemFlag = null,
          onTap: () {
            _toRecentSubscribedPage(context);
          },
          width: 64.0,
          margin: EdgeInsets.symmetric(
            horizontal: 6.0,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: ExtendedNetworkImageProvider(
                rss.entries.elementAt(0).value[0].cover,
              ),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 8.0,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: child,
        );
      },
      child: Transform.scale(
        scale: 1.08,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Center(
              child: Text(
                "更多\n更新",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toRecentSubscribedPage(BuildContext context) {
    Navigator.pushNamed(
      context,
      Routes.recentSubscribed.name,
      arguments: Routes.recentSubscribed
          .d(loaded: context.read<SubscribedModel>().records),
    );
  }

  Widget _buildRssListItemCover(
    final MapEntry<String, List<RecordItem>> entry,
  ) {
    final List<RecordItem> records = entry.value;
    final int recordsLength = records.length;
    final String bangumiCover = records[0].cover;
    final String bangumiId = entry.key;
    final String badge = recordsLength > 99 ? "99+" : "+$recordsLength";
    final String currFlag = "rss:$bangumiId:$bangumiCover";
    return Selector<IndexModel, String>(
      selector: (_, model) => model.tapBangumiRssItemFlag,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, tapScaleFlag, child) {
        final Matrix4 transform = tapScaleFlag == currFlag
            ? Matrix4.diagonal3Values(0.9, 0.9, 1)
            : Matrix4.identity();
        return AnimatedTapContainer(
          transform: transform,
          onTapStart: () =>
              context.read<IndexModel>().tapBangumiRssItemFlag = currFlag,
          onTapEnd: () =>
              context.read<IndexModel>().tapBangumiRssItemFlag = null,
          width: 64.0,
          margin: EdgeInsets.symmetric(
            horizontal: 6.0,
            vertical: 12.0,
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
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        child: Stack(
          fit: StackFit.loose,
          overflow: Overflow.clip,
          children: [
            Positioned.fill(
              child: Hero(
                tag: currFlag,
                child: ExtendedImage.network(
                  bangumiCover,
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
                    return null;
                  },
                ),
              ),
            ),
            Positioned(
              right: -20.0,
              top: -8,
              child: Transform.rotate(
                angle: Math.pi / 4.0,
                child: Container(
                  width: 48.0,
                  padding: EdgeInsets.only(top: 12.0),
                  color: Colors.redAccent,
                  child: Text(
                    badge,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
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

  Widget _buildRssRecordsSection() {
    return Selector<SubscribedModel, List<RecordItem>>(
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
            child: Text(
              "更新列表",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRssRecordsList(
    final Color accentColor,
    final Color primaryColor,
    final Color backgroundColor,
    final TextStyle fileTagStyle,
    final TextStyle titleTagStyle,
  ) {
    return Selector<SubscribedModel, List<RecordItem>>(
      selector: (_, model) => model.records,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, records, __) {
        if (records.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        final int length = records.length;
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
                    child: FlatButton(
                      onPressed: () {
                        _toRecentSubscribedPage(context);
                      },
                      child: Text("没有找到您需要的？点击查看更多"),
                    ),
                  );
                }
                final RecordItem record = records[index];
                return Selector<SubscribedModel, int>(
                  selector: (_, model) => model.tapRecordItemIndex,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (context, scaleIndex, __) {
                    final Matrix4 transform = scaleIndex == index
                        ? Matrix4.diagonal3Values(0.9, 0.9, 1)
                        : Matrix4.identity();
                    return RssRecordItem(
                      index: index,
                      record: record,
                      accentColor: accentColor,
                      primaryColor: primaryColor,
                      backgroundColor: backgroundColor,
                      fileTagStyle: fileTagStyle,
                      titleTagStyle: titleTagStyle,
                      transform: transform,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.recordDetail.name,
                          arguments: Routes.recordDetail.d(url: record.url),
                        );
                      },
                      onTapStart: () {
                        context.read<SubscribedModel>().tapRecordItemIndex =
                            index;
                      },
                      onTapEnd: () {
                        context.read<SubscribedModel>().tapRecordItemIndex =
                            null;
                      },
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
