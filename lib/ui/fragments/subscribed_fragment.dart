import 'dart:math' as Math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/internal/ui.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/providers/models/subscribed_model.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@immutable
class SubscribedFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).accentColor;
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
                // 给下拉刷新一点余地,防止抖动
                subscribedModel.hasScrolled = offset > 4.0;
              }
            }
            return true;
          },
          child: SmartRefresher(
            header: Indicator.header(
              context,
              accentColor,
              top: 16.0 + Sz.statusBarHeight,
            ),
            controller: subscribedModel.refreshController,
            enablePullDown: true,
            enablePullUp: false,
            onRefresh: subscribedModel.refresh,
            child: CustomScrollView(
              slivers: [
                Selector<SubscribedModel, bool>(
                  selector: (_, model) => model.hasScrolled,
                  builder: (_, hasScrolled, __) {
                    return SliverPinnedToBoxAdapter(
                      child: AnimatedContainer(
                        decoration: BoxDecoration(
                          color: hasScrolled
                              ? backgroundColor
                              : scaffoldBackgroundColor,
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
                                fontSize: 28,
                                height: 1.25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SliverToBoxAdapter(
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
                ),
                SliverToBoxAdapter(child: _buildRssList(backgroundColor)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                      bottom: 8.0,
                    ),
                    child: Text(
                      "季度订阅",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
                Selector<SubscribedModel, List<Bangumi>>(
                  selector: (_, model) => model.bangumis,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (context, bangumis, __) {
                    if (context.select<SubscribedModel, bool>(
                        (model) => model.seasonLoading)) {
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.0)),
                          ),
                          child: Center(child: Text(">_< 您还没有订阅任何番组，快去添加订阅吧")),
                        ),
                      );
                    }
                    return BangumiSliverGridFragment(
                      bangumis: bangumis,
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRssList(final Color backgroundColor) {
    return Selector<SubscribedModel, Map<String, List<RecordItem>>>(
      selector: (_, model) => model.rss,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, rss, __) {
        if (rss.isSafeNotEmpty)
          return SizedBox(
            height: 64.0 + 24.0,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              itemBuilder: (_, index) {
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
          width: 64.0,
          margin: EdgeInsets.symmetric(
            horizontal: 6.0,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(
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
                "更多\n订阅",
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
      shouldRebuild: (pre, next) => pre != next,
      selector: (_, model) => model.tapBangumiRssItemFlag,
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
              Routes.bangumiDetails,
              arguments: {
                "heroTag": currFlag,
                "bangumiId": bangumiId,
                "cover": bangumiCover,
              },
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
                child: CachedNetworkImage(
                  imageUrl: bangumiCover,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: SpinKitPumpingHeart(
                        duration: Duration(milliseconds: 960),
                        itemBuilder: (_, __) => Image.asset(
                          "assets/mikan.png",
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Image.asset(
                        "assets/mikan.png",
                      ),
                    ),
                  ),
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
}
