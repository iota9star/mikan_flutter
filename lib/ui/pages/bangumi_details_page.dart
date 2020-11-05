import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/internal/ui.dart';
import 'package:mikan_flutter/model/bangumi_details.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/models/bangumi_details_model.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_details_subgroup_fragment.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "/bangumi/details",
  routeName: "bangumi-details",
)
class BangumiDetailsPage extends StatefulWidget {
  final String heroTag;
  final String bangumiId;
  final String cover;

  const BangumiDetailsPage({Key key, this.bangumiId, this.cover, this.heroTag})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BangumiDetailsPageState();
}

class _BangumiDetailsPageState extends State<BangumiDetailsPage> {
  BangumiDetailsModel _bangumiDetailsModel;

  @override
  void initState() {
    _bangumiDetailsModel = BangumiDetailsModel(widget.bangumiId, widget.cover);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).accentColor;
    final Color backgroundColor = Theme.of(context).backgroundColor;
    final cover = widget.cover;
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: Scaffold(
        body: ChangeNotifierProvider<BangumiDetailsModel>(
          create: (context) => _bangumiDetailsModel,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(cover, scale: 0.25),
                    ),
                  ),
                  child: Selector<BangumiDetailsModel, Color>(
                    builder: (_, bgColor, __) {
                      final color = bgColor ?? backgroundColor;
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaY: 8.0, sigmaX: 8.0),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [color.withOpacity(0.0), color],
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
              Positioned.fill(
                child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: [
                    SliverPinnedToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.only(
                          top: Sz.statusBarHeight + 12.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        // decoration: BoxDecoration(color: backgroundColor),
                        child: Row(
                          children: [
                            MaterialButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Icon(FluentIcons.caret_left_24_regular),
                              color: backgroundColor.withOpacity(0.87),
                              minWidth: 0,
                              padding: EdgeInsets.all(10.0),
                              shape: CircleBorder(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 98.0),
                          _buildBangumiTop(
                            accentColor,
                            backgroundColor,
                            cover,
                          ),
                          _buildLoading(backgroundColor),
                          _buildBangumiBase(
                            accentColor,
                            backgroundColor,
                            cover,
                          ),
                          _buildBangumiSubgroups(
                            backgroundColor,
                            accentColor,
                          ),
                          _buildBangumiIntro(
                            backgroundColor,
                            accentColor,
                          ),
                          SizedBox(height: Sz.navBarHeight + 36.0)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(final Color backgroundColor) {
    return Selector<BangumiDetailsModel, bool>(
      selector: (_, model) => model.loading,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, loading, __) {
        if (loading) {
          return Container(
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
          );
        }
        return Container();
      },
    );
  }

  Widget _buildBangumiIntro(
    Color backgroundColor,
    Color accentColor,
  ) {
    return Selector<BangumiDetailsModel, BangumiDetails>(
      selector: (_, model) => model.bangumiDetails,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, bangumiDetails, _) {
        if (bangumiDetails == null || bangumiDetails.intro.isNullOrBlank) {
          return Container();
        }
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 8.0,
          ),
          padding: EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor.withOpacity(0.72),
                backgroundColor.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "概况简介",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                bangumiDetails.intro,
                textAlign: TextAlign.justify,
                softWrap: true,
                style: TextStyle(
                  fontSize: 16.0,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBangumiSubgroups(
    Color backgroundColor,
    Color accentColor,
  ) {
    return Selector<BangumiDetailsModel, List<SubgroupBangumi>>(
      selector: (_, model) => model.bangumiDetails?.subgroupBangumis,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, subgroups, __) {
        if (subgroups.isNullOrEmpty) {
          return Container();
        }
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor.withOpacity(0.72),
                backgroundColor.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    final String groupName = subgroups[subgroupIndex].name;
                    return ActionChip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      tooltip: groupName,
                      label: Text(
                        groupName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accentColor,
                        ),
                      ),
                      backgroundColor: accentColor.withOpacity(0.18),
                      onPressed: () {
                        _bangumiDetailsModel.selectedSubgroupId =
                            subgroups[subgroupIndex].subgroupId;
                        _showSubgroupPanel(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBangumiTop(final Color accentColor,
      final Color backgroundColor,
      final String cover,) {
    return Column(
      children: [
        Stack(
          fit: StackFit.loose,
          children: [
            Positioned.fill(
              left: 16.0,
              right: 16.0,
              child: FractionallySizedBox(
                widthFactor: 1,
                heightFactor: 0.5,
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        backgroundColor.withOpacity(0.72),
                        backgroundColor.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(16.0),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8.0,
                          color: Colors.black.withOpacity(0.08),
                        )
                      ],
                    ),
                    child: _buildBangumiCover(cover),
                  ),
                  Spacer(flex: 3),
                  MaterialButton(
                    onPressed: () {},
                    child: Icon(FluentIcons.thumb_like_24_filled),
                    color: Colors.pinkAccent,
                    padding: EdgeInsets.all(12.0),
                    minWidth: 0,
                    shape: CircleBorder(),
                  ),
                  Spacer(),
                  MaterialButton(
                    onPressed: () {},
                    child: Icon(FluentIcons.star_24_filled),
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
      ],
    );
  }

  Widget _buildBangumiBase(final Color accentColor,
      final Color backgroundColor,
      final String cover,) {
    return Selector<BangumiDetailsModel, BangumiDetails>(
      selector: (_, model) => model.bangumiDetails,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, bangumiDetails, _) {
        if (bangumiDetails == null) {
          return Container();
        }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bangumiDetails.name,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              SizedBox(height: 8.0),
              ...bangumiDetails.more.entries
                  .map((e) =>
                  Text(
                    "${e.key}: ${e.value}",
                    softWrap: true,
                    style: TextStyle(
                      height: 1.6,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Theme
                          .of(context)
                          .textTheme
                          .subtitle1
                          .color,
                    ),
                  ))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBangumiCover(String cover) {
    return ExtendedImage(
      width: 136.0,
      image: CachedNetworkImageProvider(cover),
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
                  color: Colors.black.withOpacity(0.6),
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
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
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
              image: DecorationImage(
                image: ExtendedAssetImageProvider("assets/mikan.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
              ),
            ),
          );
        } else if (value.extendedImageLoadState == LoadState.completed) {
          _bangumiDetailsModel.coverSize = Size(
            value.extendedImageInfo.image.width.toDouble(),
            value.extendedImageInfo.image.height.toDouble(),
          );
          child = Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withAlpha(24),
                )
              ],
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
              image: DecorationImage(
                image: value.imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        return AspectRatio(
          aspectRatio: _bangumiDetailsModel.coverSize == null
              ? 1
              : _bangumiDetailsModel.coverSize.width /
              _bangumiDetailsModel.coverSize.height,
          child: Hero(
            tag: widget.heroTag,
            child: child,
          ),
        );
      },
    );
  }

  _showSubgroupPanel(final BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      bounce: true,
      enableDrag: false,
      topRadius: Radius.circular(24.0),
      builder: (context, scrollController) {
        return BangumiDetailsSubgroupFragment(
          scrollController: scrollController,
          bangumiDetailsModel: _bangumiDetailsModel,
        );
      },
    );
  }

  @override
  void dispose() {
    this._bangumiDetailsModel.dispose();
    super.dispose();
  }
}
