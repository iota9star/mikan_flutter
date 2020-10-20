import 'dart:math' as Math;
import 'dart:ui';

import 'package:ant_icons/ant_icons.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/ext/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@immutable
class IndexFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).accentColor;
    final Color accentColorWithOpacity = accentColor.withOpacity(0.48);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return false;
          },
          child: CustomScrollView(
            slivers: [
              SliverPinnedToBoxAdapter(
                child: _buildHeader(context),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    _buildCarousels(),
                    _buildRssList(),
                  ],
                ),
              ),
              Selector<IndexModel, bool>(
                selector: (_, model) => model.seasonLoading,
                shouldRebuild: (pre, next) => pre != next,
                builder: (_, loading, ___) {
                  final List<BangumiRow> bangumiRows =
                      context.read<IndexModel>().bangumiRows;
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildBangumiSubgroupItemWrapper(
                          context,
                          accentColor,
                          accentColorWithOpacity,
                          bangumiRows,
                          index,
                        );
                      },
                      childCount: bangumiRows.length,
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

  Column _buildBangumiSubgroupItemWrapper(
    final BuildContext context,
    final Color accentColor,
    final Color accentColorWithOpacity,
    final List<BangumiRow> bangumiRows,
    final int index,
  ) {
    final bangumiRow = bangumiRows[index];
    final simple = [
      if (bangumiRow.updatedNum > 0) "🚀 ${bangumiRow.updatedNum}部",
      if (bangumiRow.subscribedUpdatedNum > 0)
        "💖 ${bangumiRow.subscribedUpdatedNum}部",
      if (bangumiRow.subscribedNum > 0) "❤ ${bangumiRow.subscribedNum}部",
      "🎬 ${bangumiRow.num}部"
    ].join("，");
    final full = [
      if (bangumiRow.updatedNum > 0) "更新${bangumiRow.updatedNum}部",
      if (bangumiRow.subscribedUpdatedNum > 0)
        "订阅更新${bangumiRow.subscribedUpdatedNum}部",
      if (bangumiRow.subscribedNum > 0) "订阅${bangumiRow.subscribedNum}部",
      "共${bangumiRow.num}部"
    ].join("，");
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 24.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  bangumiRow.name,
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tooltip(
                message: full,
                child: Text(
                  simple,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontSize: 12.0,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          child: _buildBangumiList(
            bangumiRow,
            200,
            accentColor,
          ),
          margin: EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
          ),
        )
      ],
    );
  }

  Widget _buildBangumiList(
    final BangumiRow row,
    final int bangumiWidth,
    final Color accentColor,
  ) {
    return WaterfallFlow.builder(
      key: PageStorageKey(row.name),
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
      itemCount: row.bangumis.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
        crossAxisCount: 3,
        collectGarbage: (List<int> garbages) {
          garbages.forEach((it) {
            CachedNetworkImageProvider(row.bangumis[it].cover).evict();
          });
        },
      ),
      itemBuilder: (BuildContext context, int index) {
        return _buildBangumiItem(
          row,
          index,
          bangumiWidth,
          accentColor,
        );
      },
    );
  }

  Widget _buildBangumiItem(
    BangumiRow row,
    int index,
    int bangumiWidth,
    Color accentColor,
  ) {
    final Bangumi bangumi = row.bangumis[index];
    final fitAccentTextColor =
        accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
    final TextStyle tagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: fitAccentTextColor,
    );
    final String currFlag = "bangumi:${bangumi.id}:${bangumi.cover}";
    return Selector<IndexModel, String>(
      builder: (context, tapScaleFlag, child) {
        Matrix4 transform;
        if (tapScaleFlag == currFlag) {
          transform = Matrix4.diagonal3Values(0.9, 0.9, 1);
        } else {
          transform = Matrix4.identity();
        }
        Widget cover = _buildBangumiListItemCover(currFlag, bangumi);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AnimatedTapContainer(
              transform: transform,
              onTapStart: () =>
                  context.read<IndexModel>().tapBangumiListItemFlag = currFlag,
              onTapEnd: () =>
                  context.read<IndexModel>().tapBangumiListItemFlag = null,
              onTap: () {
                if (bangumi.grey) {
                  "此番组下暂无作品".toast();
                } else {
                  Navigator.pushNamed(
                    context,
                    Routes.bangumiDetails,
                    arguments: {
                      "heroTag": currFlag,
                      "bangumiId": bangumi.id,
                      "cover": bangumi.cover,
                    },
                  );
                }
              },
              child: Stack(
                children: [
                  cover,
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: bangumi.grey
                            ? Colors.grey
                            : accentColor.withOpacity(0.87),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        bangumi.updateAt,
                        textAlign: TextAlign.center,
                        style: tagStyle,
                      ),
                    ),
                  ),
                  Positioned(
                    child: bangumi.subscribed
                        ? SizedBox(
                            width: 32.0,
                            height: 32.0,
                            child: IconButton(
                              tooltip: "取消订阅",
                              padding: EdgeInsets.all(4.0),
                              icon: Icon(
                                AntIcons.heart,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                context
                                    .read<IndexModel>()
                                    .subscribeBangumi(row, index);
                              },
                            ),
                          )
                        : Container(
                            width: 26.0,
                            height: 26.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.black38,
                            ),
                            child: IconButton(
                              tooltip: "订阅",
                              padding: EdgeInsets.all(4.0),
                              iconSize: 18.0,
                              icon: Icon(
                                AntIcons.heart_outline,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                context
                                    .read<IndexModel>()
                                    .subscribeBangumi(row, index);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 6.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 4,
                  height: 12,
                  margin: EdgeInsets.only(top: 2.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        bangumi.grey ? Colors.grey : accentColor,
                        accentColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                SizedBox(width: 4.0),
                Expanded(
                  child: Text(
                    bangumi.name,
                    style: TextStyle(
                      fontSize: 14.0,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      selector: (_, model) => model.tapBangumiListItemFlag,
      shouldRebuild: (pre, next) => pre != next,
    );
  }

  Widget _buildBangumiListItemCover(
      final String currFlag, final Bangumi bangumi) {
    Widget widget = ExtendedImage(
      image: CachedNetworkImageProvider(bangumi.cover),
      shape: BoxShape.rectangle,
      clearMemoryCacheWhenDispose: true,
      loadStateChanged: (ExtendedImageState value) {
        Widget child;
        if (value.extendedImageLoadState == LoadState.loading) {
          child = Container(
            padding: EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withAlpha(24),
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: SpinKitPumpingHeart(
                duration: Duration(milliseconds: 960),
                itemBuilder: (_, __) => Image.asset(
                  "assets/mikan.png",
                ),
              ),
            ),
          );
        }
        if (value.extendedImageLoadState == LoadState.failed) {
          child = Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withAlpha(24),
                )
              ],
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                image: ExtendedAssetImageProvider("assets/mikan.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
              ),
            ),
          );
        } else if (value.extendedImageLoadState == LoadState.completed) {
          bangumi.coverSize = Size(
              value.extendedImageInfo.image.width.toDouble(),
              value.extendedImageInfo.image.height.toDouble());
          child = Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withAlpha(24),
                )
              ],
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                image: value.imageProvider,
                fit: BoxFit.cover,
                colorFilter: bangumi.grey
                    ? ColorFilter.mode(Colors.grey, BlendMode.color)
                    : null,
              ),
            ),
          );
        }
        return AspectRatio(
          aspectRatio: bangumi.coverSize == null
              ? 1
              : bangumi.coverSize.width / bangumi.coverSize.height,
          child: Hero(
            tag: currFlag,
            child: child,
          ),
        );
      },
    );
    if (bangumi.num > 0) {
      String badge;
      if (bangumi.num > 99) {
        badge = "99+";
      } else {
        badge = "+${bangumi.num}";
      }
      widget = Badge(
        badgeColor: Colors.redAccent,
        toAnimate: false,
        padding: EdgeInsets.all(4.0),
        badgeContent: Text(
          badge,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.white,
            height: 1.25,
          ),
        ),
        child: widget,
      );
    }
    return widget;
  }

  Widget _buildRssList() {
    return Selector<IndexModel, Map<String, List<RecordItem>>>(
      selector: (_, model) => model.rss,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, rss, __) {
        if (rss.isNotEmpty)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: 8.0,
                ),
                child: Text(
                  "我的订阅 ❤ 昨日至今",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ),
              SizedBox(
                height: 64.0 + 16.0,
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
              ),
            ],
          );
        return Container();
      },
    );
  }

  Selector<IndexModel, String> _buildMoreRssItemBtn(BuildContext context,
      Map<String, List<RecordItem>> rss) {
    return Selector<IndexModel, String>(
      selector: (_, model) => model.tapBangumiRssItemFlag,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, tapScaleFlag, child) {
        Matrix4 transform;
        final String currFlag = "rss:more-rss";
        if (tapScaleFlag == currFlag) {
          transform = Matrix4.diagonal3Values(0.9, 0.9, 1);
        } else {
          transform = Matrix4.identity();
        }
        return AnimatedTapContainer(
          transform: transform,
          onTapStart: () =>
          context
              .read<IndexModel>()
              .tapBangumiRssItemFlag = currFlag,
          onTapEnd: () =>
          context
              .read<IndexModel>()
              .tapBangumiRssItemFlag = null,
          width: 64.0,
          margin: EdgeInsets.symmetric(
            horizontal: 6.0,
            vertical: 8.0,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(
                rss.entries
                    .elementAt(0)
                    .value[0].cover,
              ),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 8.0,
                color: Colors.black.withAlpha(24),
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Center(
            child: Text(
              "更多\n订阅",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme
                    .of(context)
                    .accentColor,
                height: 1.25,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRssListItemCover(
      final MapEntry<String, List<RecordItem>> entry,) {
    final List<RecordItem> records = entry.value;
    final int recordsLength = records.length;
    final String bangumiCover = records[0].cover;
    final String bangumiId = entry.key;
    String badge;
    if (recordsLength > 99) {
      badge = "99+";
    } else {
      badge = "+$recordsLength";
    }
    final String currFlag = "rss:$bangumiId:$bangumiCover";
    return Selector<IndexModel, String>(
      shouldRebuild: (pre, next) => pre != next,
      selector: (_, model) => model.tapBangumiRssItemFlag,
      builder: (context, tapScaleFlag, child) {
        Matrix4 transform;
        if (tapScaleFlag == currFlag) {
          transform = Matrix4.diagonal3Values(0.9, 0.9, 1);
        } else {
          transform = Matrix4.identity();
        }
        return AnimatedTapContainer(
          transform: transform,
          onTapStart: () =>
          context
              .read<IndexModel>()
              .tapBangumiRssItemFlag = currFlag,
          onTapEnd: () =>
          context
              .read<IndexModel>()
              .tapBangumiRssItemFlag = null,
          width: 64.0,
          margin: EdgeInsets.symmetric(
            horizontal: 6.0,
            vertical: 8.0,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 8.0,
                color: Colors.black.withAlpha(24),
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
                  placeholder: (_, __) =>
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: SpinKitPumpingHeart(
                            duration: Duration(milliseconds: 960),
                            itemBuilder: (_, __) =>
                                Image.asset(
                                  "assets/mikan.png",
                                ),
                          ),
                        ),
                      ),
                  errorWidget: (_, __, ___) =>
                      Padding(
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
                  padding: EdgeInsets.only(top: 10.0),
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

  Widget _buildCarousels() {
    return Selector<IndexModel, List<Carousel>>(
      selector: (_, model) => model.carousels,
      shouldRebuild: (pre, next) => pre.length != next.length,
      builder: (context, carousels, __) {
        if (carousels.isNotEmpty)
          return CarouselSlider.builder(
            itemBuilder: (context, index) {
              final carousel = carousels[index];
              final String currFlag =
                  "carousel:${carousel.id}:${carousel.cover}";
              return Selector<IndexModel, String>(
                selector: (_, model) => model.tapBangumiCarouselItemFlag,
                shouldRebuild: (pre, next) => pre != next,
                builder: (context, tapScaleFlag, child) {
                  Matrix4 transform;
                  if (tapScaleFlag == currFlag) {
                    transform = Matrix4.diagonal3Values(0.8, 0.8, 1.0);
                  } else {
                    transform = Matrix4.identity();
                  }
                  return Hero(
                    tag: currFlag,
                    child: AnimatedTapContainer(
                      transform: transform,
                      onTapStart: () =>
                      context
                          .read<IndexModel>()
                          .tapBangumiCarouselItemFlag = currFlag,
                      onTapEnd: () =>
                      context
                          .read<IndexModel>()
                          .tapBangumiCarouselItemFlag = null,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.bangumiDetails,
                          arguments: {
                            "heroTag": currFlag,
                            "bangumiId": carousel.id,
                            "cover": carousel.cover,
                          },
                        );
                      },
                      margin: EdgeInsets.only(top: 12.0, bottom: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        color: Theme
                            .of(context)
                            .backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.08),
                          )
                        ],
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                            carousel.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            itemCount: carousels.length,
            options: CarouselOptions(
              height: 180,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
              autoPlay: true,
              enlargeCenterPage: true,
            ),
          );
        return Container();
      },
    );
  }

  Widget _buildHeader(final BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 36.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .scaffoldBackgroundColor,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Selector<IndexModel, User>(
                  builder: (_, user, __) {
                    final withoutName = user == null || user.name.isNullOrBlank;
                    return Text(
                      withoutName ? "Welcome to Mikan" : "Hi, ${user.name}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                  selector: (_, model) => model.user,
                  shouldRebuild: (pre, next) => pre != next,
                ),
                Row(
                  children: [
                    Selector<IndexModel, Season>(
                      selector: (_, model) => model.selectedSeason,
                      shouldRebuild: (pre, next) => pre != next,
                      builder: (_, season, __) {
                        return season == null
                            ? Container()
                            : Text(
                          season.title,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    MaterialButton(
                      onPressed: () {
                        _showYearSeasonBottomSheet(context);
                      },
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 16.0,
                      ),
                      minWidth: 0,
                      color: Theme
                          .of(context)
                          .backgroundColor,
                      padding: EdgeInsets.all(6.0),
                      shape: CircleBorder(),
                    ),
                  ],
                )
              ],
            ),
          ),
          MaterialButton(
            onPressed: () {},
            child: Icon(
              AntIcons.search_outline,
            ),
            minWidth: 0,
            padding: EdgeInsets.all(10.0),
            shape: CircleBorder(),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.login);
            },
            child: Selector<IndexModel, User>(
              selector: (_, model) => model.user,
              shouldRebuild: (pre, next) => pre != next,
              builder: (_, user, __) {
                return user?.avatar?.isNotBlank == true
                    ? ClipOval(
                  child: CachedNetworkImage(
                    width: 36.0,
                    height: 36.0,
                    imageUrl: user?.avatar,
                    placeholder: (_, __) =>
                        Image.asset(
                          "assets/mikan.png",
                          width: 36.0,
                          height: 36.0,
                        ),
                    errorWidget: (_, __, ___) =>
                        Image.asset(
                          "assets/mikan.png",
                          width: 36.0,
                          height: 36.0,
                        ),
                  ),
                )
                    : Image.asset(
                  "assets/mikan.png",
                  width: 36.0,
                  height: 36.0,
                );
              },
            ),
            minWidth: 0,
            padding: EdgeInsets.all(10.0),
            shape: CircleBorder(),
          ),
        ],
      ),
    );
  }

  Future _showYearSeasonBottomSheet(BuildContext context) {
    return showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      builder: (context, controller) {
        return Material(
          color: Theme
              .of(context)
              .backgroundColor,
          child: SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 16.0 + Sz.navBarHeight,
              ),
              child: Selector<IndexModel, List<YearSeason>>(
                selector: (_, model) => model.years,
                shouldRebuild: (pre, next) => pre != next,
                builder: (_, years, __) {
                  if (years.isNullOrEmpty) return Container();
                  final widgets = List.generate(
                    years.length,
                        (index) {
                      final year = years[index];
                      return Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            year.year,
                            style: TextStyle(
                              fontSize: 20.0,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 16.0),
                          ...List.generate(
                            4,
                                (index) {
                              if (year.seasons.length > index) {
                                return _buildSeasonItem(year.seasons[index]);
                              } else {
                                return Flexible(
                                  child: FractionallySizedBox(widthFactor: 1),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "番组列表",
                        style: TextStyle(
                          fontSize: 24.0,
                          height: 1.25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.0),
                      ...widgets
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Flexible _buildSeasonItem(final Season season) {
    return Flexible(
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Selector<IndexModel, Season>(
            selector: (_, model) => model.selectedSeason,
            shouldRebuild: (pre, next) => pre != next,
            builder: (context, selectedSeason, _) {
              return MaterialButton(
                minWidth: 0,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Text(
                  season.season,
                  style: TextStyle(
                    fontSize: 18.0,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    color: Theme
                        .of(context)
                        .accentColor,
                  ),
                ),
                color: season.title == selectedSeason.title
                    ? Theme
                    .of(context)
                    .accentColor
                    .withOpacity(0.36)
                    : Theme
                    .of(context)
                    .accentColor
                    .withOpacity(0.08),
                elevation: 0,
                onPressed: () {
                  context.read<IndexModel>().loadSeason(season);
                },
              );
            },
          ),
        ),
      ),
    );
  }
// Future _showYearSeasonBottomSheet(BuildContext context) {
//   return showCupertinoModalBottomSheet(
//     context: context,
//     expand: false,
//     builder: (context, controller) {
//       return Material(
//         color: Theme.of(context).backgroundColor,
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16.0,
//             right: 16.0,
//             top: 16.0,
//             bottom: 16.0 + Sz.navBarHeight,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "番组列表",
//                 style: TextStyle(
//                   fontSize: 24.0,
//                   height: 1.25,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 12.0),
//               Expanded(
//                 child: Selector<IndexModel, List<YearSeason>>(
//                   selector: (_, model) => model.years,
//                   shouldRebuild: (pre, next) => pre != next,
//                   builder: (_, years, __) {
//                     return ListView.builder(
//                       itemCount: years.length,
//                       controller: controller,
//                       itemBuilder: (context, index) {
//                         final year = years[index];
//                         return Row(
//                           mainAxisSize: MainAxisSize.max,
//                           children: [
//                             Text(
//                               year.year,
//                               style: TextStyle(
//                                 fontSize: 20.0,
//                                 height: 1.25,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             SizedBox(width: 16.0),
//                             ...List.generate(
//                               4,
//                               (index) {
//                                 if (year.seasons.length > index) {
//                                   final String season =
//                                       year.seasons[index].season;
//                                   return Flexible(
//                                     child: FractionallySizedBox(
//                                       widthFactor: 1,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: MaterialButton(
//                                           minWidth: 0,
//                                           materialTapTargetSize:
//                                               MaterialTapTargetSize
//                                                   .shrinkWrap,
//                                           padding: EdgeInsets.all(0.0),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.all(
//                                               Radius.circular(10.0),
//                                             ),
//                                           ),
//                                           child: Text(
//                                             season,
//                                             style: TextStyle(
//                                               fontSize: 18.0,
//                                               height: 1.25,
//                                               fontWeight: FontWeight.w500,
//                                               color: Theme.of(context)
//                                                   .accentColor,
//                                             ),
//                                           ),
//                                           color: Theme.of(context)
//                                               .accentColor
//                                               .withOpacity(0.3),
//                                           elevation: 0,
//                                           onPressed: () {},
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 } else {
//                                   return Flexible(
//                                     child:
//                                         FractionallySizedBox(widthFactor: 1),
//                                   );
//                                 }
//                               },
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               )
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
}
