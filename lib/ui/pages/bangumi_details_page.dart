import 'dart:ui';

import 'package:ant_icons/ant_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/ext/screen.dart';
import 'package:mikan_flutter/ext/state.dart';
import 'package:mikan_flutter/providers/models/bangumi_details_model.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_details_page_selected_subgroup_list.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

@FFRoute(
  name: "mikan://bangumi-home",
  routeName: "bangumi-home",
)
class BangumiHomePage extends StatefulWidget {
  final String bangumiId;
  final String cover;

  const BangumiHomePage({Key key, this.bangumiId, this.cover})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BangumiHomePageState();
}

class _BangumiHomePageState extends CacheWidgetState<BangumiHomePage>
    with SingleTickerProviderStateMixin {
  @override
  Widget buildCacheWidget(BuildContext context) {
    final String heroTag = "${widget.bangumiId}:${widget.cover}";
    final Color accentColor = Theme.of(context).accentColor;
    final Color scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      body: ChangeNotifierProvider<BangumiHomeModel>(
        create: (context) => BangumiHomeModel(widget.bangumiId, widget.cover),
        child: Selector<BangumiHomeModel, bool>(
          builder: (context, loading, child) {
            final cover = widget.cover;
            if (loading) {
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
                            image: CachedNetworkImageProvider(cover),
                          ),
                        ),
                        child: Selector<BangumiHomeModel, Color>(
                          builder: (_, color, __) {
                            return BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaY: 16.0, sigmaX: 16.0),
                              child: Container(
                                color: color?.withOpacity(0.38),
                                child: Center(
                                  child: CupertinoActivityIndicator(
                                    radius: 24.0,
                                  ),
                                ),
                              ),
                            );
                          },
                          selector: (_, model) => model.coverMainColor,
                          shouldRebuild: (pre, next) => pre != next,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            final model = Provider.of<BangumiHomeModel>(context, listen: false);
            final subgroups = model.bangumiHome.subgroupBangumis;
            return SlidingUpPanel(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 480.0 + Sz.statusBarHeight,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(cover),
                        ),
                      ),
                      child: Selector<BangumiHomeModel, Color>(
                        builder: (_, color, __) {
                          return BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaY: 16.0, sigmaX: 16.0),
                            child: Container(
                              color: color?.withOpacity(0.38) ??
                                  Colors.transparent,
                            ),
                          );
                        },
                        selector: (_, model) => model.coverMainColor,
                        shouldRebuild: (pre, next) => pre != next,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomScrollView(
                      physics: BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: Sz.statusBarHeight + 160.0,
                              ),
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
                                          color: scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(24.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24.0, vertical: 12.0),
                                    child: Row(
                                      children: [
                                        Container(
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
                                          ),
                                          child: ExtendedImage(
                                            width: 136.0,
                                            image: CachedNetworkImageProvider(
                                                cover),
                                            shape: BoxShape.rectangle,
                                            clearMemoryCacheWhenDispose: true,
                                            loadStateChanged:
                                                (ExtendedImageState value) {
                                              Widget child;
                                              if (value
                                                      .extendedImageLoadState ==
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
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(10.0),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: SpinKitPumpingHeart(
                                                      duration: Duration(
                                                          milliseconds: 960),
                                                      itemBuilder: (_, __) =>
                                                          Image.asset(
                                                        "assets/mikan.png",
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              if (value
                                                      .extendedImageLoadState ==
                                                  LoadState.failed) {
                                                child = Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 8.0,
                                                        color: Colors.black
                                                            .withAlpha(24),
                                                      )
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                    image: DecorationImage(
                                                      image:
                                                          ExtendedAssetImageProvider(
                                                              "assets/mikan.png"),
                                                      fit: BoxFit.cover,
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                              Colors.grey,
                                                              BlendMode.color),
                                                    ),
                                                  ),
                                                );
                                              } else if (value
                                                      .extendedImageLoadState ==
                                                  LoadState.completed) {
                                                model.bangumiHome.coverSize =
                                                    Size(
                                                        value.extendedImageInfo
                                                            .image.width
                                                            .toDouble(),
                                                        value.extendedImageInfo
                                                            .image.height
                                                            .toDouble());
                                                child = Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 8.0,
                                                        color: Colors.black
                                                            .withAlpha(24),
                                                      )
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                    image: DecorationImage(
                                                      image:
                                                          value.imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return AspectRatio(
                                                aspectRatio: model.bangumiHome
                                                            .coverSize ==
                                                        null
                                                    ? 1
                                                    : model.bangumiHome
                                                            .coverSize.width /
                                                        model.bangumiHome
                                                            .coverSize.height,
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
                              Transform.translate(
                                // use translateY -1 pixel to remove gap.
                                offset: Offset(0, -1),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                    left: 24.0,
                                    right: 24.0,
                                    top: 12.0,
                                    bottom: 24.0 + Sz.navBarHeight,
                                  ),
                                  color: scaffoldBackgroundColor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        model.bangumiHome.name,
                                        style: TextStyle(
                                          color: accentColor,
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
                                      SizedBox(height: 24.0),
                                      Text(
                                        "字幕组",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                        ),
                                      ),
                                      SizedBox(height: 12.0),
                                      Wrap(
                                        spacing: 14.0,
                                        runSpacing: 14.0,
                                        children: List.generate(
                                          subgroups.length,
                                          (subgroupIndex) {
                                            final String groupName =
                                                subgroups[subgroupIndex].name;
                                            return ActionChip(
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              tooltip: groupName,
                                              label: Text(
                                                groupName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: accentColor,
                                                ),
                                              ),
                                              backgroundColor:
                                                  Color(0xfff2f2f3),
                                              onPressed: () {
                                                model.selectedSubgroupId =
                                                    subgroups[subgroupIndex]
                                                        .subgroupId;
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      if (model
                                          .bangumiHome.intro.isNotBlank) ...[
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
                                          softWrap: true,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            height: 1.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
              // panelSnapping: false,
              minHeight: 0,
              maxHeight: Sz.screenHeight,
              color: Colors.transparent,
              // onPanelClosed: () {},
              // onPanelOpened: () {},
              // onPanelSlide: (double position) {},
              panelBuilder: (ScrollController controller) {
                return WillPopScope(
                  child: Container(
                    height: double.infinity,
                    color: scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                              top: 18.0 + Sz.statusBarHeight,
                              left: 24.0,
                              right: 24.0,
                              bottom: 16.0),
                          decoration: BoxDecoration(
                              color: scaffoldBackgroundColor,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8.0,
                                  color: Colors.black.withAlpha(24),
                                )
                              ],
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(24.0),
                                bottomRight: Radius.circular(24.0),
                              )),
                          child: Column(
                            children: [
                              Container(
                                width: 30,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                              ),
                              SizedBox(
                                height: 16.0,
                              ),
                              Text(
                                model?.subgroupBangumi?.name ?? "",
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: BangumiDetailsPageSelectedSubgroupList(
                            scrollController: controller,
                          ),
                        )
                      ],
                    ),
                  ),
                  onWillPop: () async {
                    if (model.panelController.isPanelShown &&
                        !model.panelController.isPanelClosed) {
                      model.panelController.animatePanelToPosition(
                        0,
                        duration: Duration(
                          milliseconds: 240,
                        ),
                      );
                      return false;
                    }
                    return true;
                  },
                );
              },
            );
          },
          selector: (_, model) => model.loading,
          shouldRebuild: (pre, next) => pre != next,
        ),
      ),
    );
  }
}
