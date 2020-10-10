import 'dart:ui';

import 'package:ant_icons/ant_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/ext/screen.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/providers/models/bangumi_details_model.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

@FFRoute(
  name: "mikan://bangumi-home",
  routeName: "bangumi-home",
)
class BangumiHomePage extends StatefulWidget {
  final Bangumi bangumi;

  const BangumiHomePage({Key key, this.bangumi}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BangumiHomePageState();
}

class _BangumiHomePageState extends State<BangumiHomePage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final String heroTag = "${widget.bangumi.id}:${widget.bangumi.cover}";
    return Scaffold(
      body: ChangeNotifierProvider<BangumiHomeModel>(
        create: (context) => BangumiHomeModel(widget.bangumi.id, this),
        child: Consumer<BangumiHomeModel>(builder: (context, model, child) {
          if (model.loading) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Hero(
                    tag: heroTag,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image:
                          CachedNetworkImageProvider(widget.bangumi.cover),
                        ),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaY: 16.0, sigmaX: 16.0),
                        child: Container(
                          child: Center(
                            child: CupertinoActivityIndicator(
                              radius: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return SlidingUpPanel(
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 280,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(widget.bangumi.cover),
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaY: 10.0, sigmaX: 10.0),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 180.0,
                  left: 0,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        fit: StackFit.loose,
                        children: [
                          Positioned.fill(
                            child: FractionallySizedBox(
                              widthFactor: 1,
                              heightFactor: 0.5,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 8.0,
                                        color: Colors.black.withAlpha(24),
                                      )
                                    ],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  child: ExtendedImage(
                                    width: 136.0,
                                    image: CachedNetworkImageProvider(
                                        widget.bangumi.cover),
                                    shape: BoxShape.rectangle,
                                    clearMemoryCacheWhenDispose: true,
                                    loadStateChanged:
                                        (ExtendedImageState value) {
                                      Widget child;
                                      if (value.extendedImageLoadState ==
                                          LoadState.loading) {
                                        child = Container(
                                          padding: EdgeInsets.all(28.0),
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 8.0,
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                              ),
                                            ],
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          child: Center(
                                            child: SpinKitPumpingHeart(
                                              duration:
                                                  Duration(milliseconds: 960),
                                              itemBuilder: (_, __) =>
                                                  Image.asset(
                                                "assets/mikan.png",
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      if (value.extendedImageLoadState ==
                                          LoadState.failed) {
                                        child = Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 8.0,
                                                color:
                                                    Colors.black.withAlpha(24),
                                              )
                                            ],
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            image: DecorationImage(
                                              image: ExtendedAssetImageProvider(
                                                  "assets/mikan.png"),
                                              fit: BoxFit.cover,
                                              colorFilter: ColorFilter.mode(
                                                  Colors.grey, BlendMode.color),
                                            ),
                                          ),
                                        );
                                      } else if (value.extendedImageLoadState ==
                                          LoadState.completed) {
                                        widget.bangumi.coverSize = Size(
                                            value.extendedImageInfo.image.width
                                                .toDouble(),
                                            value.extendedImageInfo.image.height
                                                .toDouble());
                                        child = Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 8.0,
                                                color:
                                                    Colors.black.withAlpha(24),
                                              )
                                            ],
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            image: DecorationImage(
                                              image: value.imageProvider,
                                              fit: BoxFit.cover,
                                              colorFilter: widget.bangumi.grey
                                                  ? ColorFilter.mode(
                                                      Colors.grey,
                                                      BlendMode.color)
                                                  : null,
                                            ),
                                          ),
                                        );
                                      }
                                      return AspectRatio(
                                        aspectRatio: widget.bangumi.coverSize ==
                                                null
                                            ? 1
                                            : widget.bangumi.coverSize.width /
                                                widget.bangumi.coverSize.height,
                                        child: Hero(
                                          tag: heroTag,
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Spacer(flex: 3),
                                MaterialButton(
                                  onPressed: () {},
                                  child: Icon(
                                    AntIcons.like,
                                  ),
                                  color: Colors.pinkAccent,
                                  padding: EdgeInsets.all(12.0),
                                  minWidth: 0,
                                  shape: CircleBorder(),
                                ),
                                Spacer(),
                                MaterialButton(
                                  onPressed: () {},
                                  child: Icon(
                                    AntIcons.star,
                                  ),
                                  color: Colors.blueAccent,
                                  minWidth: 0,
                                  padding: EdgeInsets.all(16.0),
                                  shape: CircleBorder(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 24.0,
                          right: 24.0,
                          top: 16.0,
                          bottom: 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.bangumi.name,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            ...model.bangumiHome.more.entries
                                .map((e) => Text(
                                      "${e.key}: ${e.value}",
                                      softWrap: true,
                                      style: TextStyle(
                                        height: 1.6,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .color,
                                      ),
                                    ))
                                .toList(),
                            if (model.bangumiHome.intro.isNotBlank) ...[
                              SizedBox(height: 24.0),
                              Text(
                                "概况简介",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                model.bangumiHome.intro,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            controller: model.panelController,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8.0,
              )
            ],
            minHeight: 48.0,
            maxHeight: Sz.screenHeight,
            color: Colors.transparent,
            onPanelClosed: () {
              model.cropping = 1.0;
            },
            onPanelOpened: () {},
            onPanelSlide: (double position) {
              final double off = Sz.screenHeight - Sz.screenHeight * position;
              if (off <= Sz.statusBarHeight) {
                model.cropping = off / Sz.statusBarHeight;
              }
            },
            panelBuilder: (ScrollController controller) {
              return WillPopScope(
                child: CustomScrollView(
                  slivers: [
                    SliverPinnedToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24.0),
                          ),
                        ),
                        child: Column(
                          children: [
                            Selector<BangumiHomeModel, double>(
                              selector: (_, model) => model.cropping,
                              shouldRebuild: (pre, next) => pre != next,
                              child: Center(
                                child: Container(
                                  width: 30,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                  ),
                                ),
                              ),
                              builder: (BuildContext context, double cropping,
                                  Widget child) {
                                final Radius radius =
                                Radius.circular(18.0 * cropping);
                                return Container(
                                  padding: EdgeInsets.only(
                                    top: 12.0 +
                                        (1.0 - cropping) * Sz.statusBarHeight,
                                    bottom: 18.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: radius,
                                      topRight: radius,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                            ),
                            TabBar(
                              controller: model.tabController,
                              isScrollable: false,
                              tabs: List.generate(
                                model.bangumiHome.subgroupBangumis.length,
                                    (index) => Tab(
                                  text: model
                                      .bangumiHome.subgroupBangumis[index].name,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: TabBarView(
                          controller: model.tabController,
                          children: List.generate(
                              model.bangumiHome.subgroupBangumis.length,
                                  (index) {
                                return SmartRefresher(
                                  controller: model.refreshControllers[index],
                                  footer: Indicator.footer(
                                    context,
                                    Theme.of(context).accentColor,
                                    bottom: 16.0,
                                  ),
                                  enablePullDown: false,
                                  enablePullUp: true,
                                  child: ListView.builder(
                                      itemCount: model.bangumiHome
                                          .subgroupBangumis[index].records.length,
                                      itemBuilder: (context, ind) {
                                        return Text(
                                          model.bangumiHome.subgroupBangumis[index]
                                              .records[ind].title,
                                        );
                                      }),
                                );
                              }),
                        ),
                      ),
                    ),
                  ],
                ),
                onWillPop: () async {
                  if (model.panelController.isPanelShown &&
                      !model.panelController.isPanelClosed) {
                    model.panelController.close();
                    return false;
                  }
                  return true;
                },
              );
            },
          );
        }),
      ),
    );
  }
}
