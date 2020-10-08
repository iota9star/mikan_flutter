import 'dart:math' as Math;

import 'package:ant_icons/ant_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/ext/face.dart';
import 'package:mikan_flutter/ext/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@immutable
class IndexFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).accentColor;

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  _buildSearchUI(context),
                  _buildCarouselsUI(),
                ],
              ),
            ),
            SliverPinnedToBoxAdapter(
              child: _buildWeekSectionControlUI(context),
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
                      return Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 16,
                              ),
                              Container(
                                width: 6,
                                height: 18,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      accentColor,
                                      accentColor.withOpacity(0.6), // 灰蓝也还行
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2)),
                                ),
                              ),
                              SizedBox(width: 6.0),
                              Expanded(
                                child: Text(
                                  bangumiRows[index].name,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          _buildBangumiList(
                            bangumiRows[index],
                            200,
                            accentColor,
                          )
                        ],
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
    final TextStyle tagStyle = TextStyle(
      fontSize: 10,
      color: accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    final List<Widget> tags = [
      if (bangumi.subscribed)
        Container(
          margin: EdgeInsets.only(right: 4.0, bottom: 4.0),
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Text(
            "已订阅",
            style: tagStyle,
          ),
        ),
      if (bangumi.num > 0)
        Container(
          margin: EdgeInsets.only(right: 4.0, bottom: 4.0),
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Text(
            bangumi.num.toString(),
            style: tagStyle,
          ),
        ),
      Container(
        margin: EdgeInsets.only(right: 4.0, bottom: 4.0),
        padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.87),
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Text(
          bangumi.updateAt,
          style: tagStyle,
        ),
      ),
    ];
    return Selector<IndexModel, String>(
      builder: (context, tapScaleIndex, child) {
        Matrix4 transform;
        final String currFlag = "${row.name}:$index";
        if (tapScaleIndex == currFlag) {
          transform = Matrix4.diagonal3Values(0.9, 0.9, 1);
        } else {
          transform = Matrix4.identity();
        }
        return AnimatedTapContainer(
          transform: transform,
          onTapStart: () =>
              context.read<IndexModel>().tapBangumiFlag = "${row.name}:$index",
          onTapEnd: () => context.read<IndexModel>().tapBangumiFlag = null,
          onTap: () {
            if (bangumi.grey) {
              "此番组下暂无作品".toast();
            } else {
              Navigator.pushNamed(
                context,
                Routes.mikanBangumiHome,
                arguments: {
                  "bangumi": bangumi,
                },
              );
            }
          },
          child: child,
        );
      },
      selector: (_, model) => model.tapBangumiFlag,
      shouldRebuild: (pre, next) => pre != next,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ExtendedImage(
            image: CachedNetworkImageProvider(
              "${bangumi.cover}?width=$bangumiWidth&format=jpg",
            ),
            shape: BoxShape.rectangle,
            clearMemoryCacheWhenDispose: true,
            loadStateChanged: (ExtendedImageState value) {
              if (value.extendedImageLoadState == LoadState.loading) {
                return AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    padding: EdgeInsets.all(28.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8.0,
                          color: Colors.black.withAlpha(24),
                        )
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
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
                return AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    padding: EdgeInsets.all(28.0),
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
                        colorFilter:
                            ColorFilter.mode(Colors.grey, BlendMode.color),
                      ),
                    ),
                  ),
                );
              } else if (value.extendedImageLoadState == LoadState.completed) {
                bangumi.coverSize = Size(
                    value.extendedImageInfo.image.width.toDouble(),
                    value.extendedImageInfo.image.height.toDouble());
                return AspectRatio(
                  aspectRatio:
                      bangumi.coverSize.width / bangumi.coverSize.height,
                  child: Container(
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
                  ),
                );
              }
              return null;
            },
          ),
          SizedBox(
            height: 8.0,
          ),
          Wrap(
            children: tags,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 4,
                height: 10,
                margin: EdgeInsets.only(top: 4.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bangumi.grey ? Colors.grey : accentColor,
                      accentColor.withOpacity(0.16), // 灰蓝也还行
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
                    fontSize: 14,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLoader() {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SpinKitPumpingHeart(
              duration: Duration(milliseconds: 960),
              itemBuilder: (_, __) => Image.asset(
                "assets/mikan.png",
                width: 108.0,
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              randomFace(),
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              "请不要走开，精彩马上就来",
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselsUI() {
    return Selector<IndexModel, List<Carousel>>(
      selector: (_, model) => model.carousels,
      shouldRebuild: (pre, next) => pre.length != next.length,
      builder: (_, carousels, __) {
        if (carousels.isNotEmpty)
          return SizedBox(
            width: double.infinity,
            height: (Sz.screenWidth - 32) / (375 / 196) + 32,
            child: Swiper(
              autoplay: true,
              duration: 480,
              autoplayDelay: 4800,
              itemWidth: Sz.screenWidth - 32,
              layout: SwiperLayout.STACK,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(top: 12.0, bottom: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black.withAlpha(24),
                      )
                    ],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(
                        carousels[index].cover,
                      ),
                    ),
                  ),
                );
              },
              itemCount: carousels.length,
            ),
          );
        return Container();
      },
    );
  }

  Widget _buildWeekSectionControlUI(final BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        top: 12.0,
        bottom: 12.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Welcome to Mikan",
                ),
                Selector<IndexModel, Season>(
                  selector: (_, model) => model.selectedSeason,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (_, season, __) {
                    return season == null
                        ? Container()
                        : Text(
                            season.title,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          );
                  },
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(AntIcons.double_left),
                  tooltip: "上一季度",
                  onPressed: () {
                    context.read<IndexModel>().prevSeason();
                  },
                ),
                IconButton(
                  icon: Icon(AntIcons.calendar_outline),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Transform.rotate(
                    angle: Math.pi,
                    child: Icon(AntIcons.double_left),
                  ),
                  tooltip: "下一季度",
                  onPressed: () {
                    context.read<IndexModel>().nextSeason();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchUI(final BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0, bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: Icon(AntIcons.search_outline),
                labelText: 'Search for anime',
                border: InputBorder.none,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
              onEditingComplete: () {},
            ),
          ),
          Ink(
            decoration: ShapeDecoration(
              shape: CircleBorder(),
            ),
            child: IconButton(
              iconSize: 36.0,
              icon: Selector<IndexModel, User>(
                selector: (_, model) => model.user,
                shouldRebuild: (pre, next) => pre != next,
                builder: (_, user, __) {
                  return user?.avatar?.isNotBlank == true
                      ? CircleAvatar(
                          child: CachedNetworkImage(
                            imageUrl: user?.avatar,
                            placeholder: (_, __) =>
                                Image.asset("assets/mikan.png"),
                            errorWidget: (_, __, ___) =>
                                Image.asset("assets/mikan.png"),
                          ),
                        )
                      : Image.asset("assets/mikan.png");
                },
              ),
              onPressed: () {
                Navigator.pushNamed(context, Routes.mikanLogin);
              },
            ),
          )
        ],
      ),
    );
  }
}
