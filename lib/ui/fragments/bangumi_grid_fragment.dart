import 'dart:math' as Math;
import 'dart:ui';

import 'package:ant_icons/ant_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class BangumiGridFragment extends StatelessWidget {
  final List<Bangumi> bangumis;
  final ValueNotifier<double> scrollNotifier;

  BangumiGridFragment({Key key, this.bangumis, this.scrollNotifier})
      : super(key: key);

  final double wrapperHeight = Sz.screenHeight / 2;
  final double sectionHeight = 57;
  final double itemHeight = (Sz.screenWidth - 32 - 32) / 3 + 40 + 16;

  Widget _buildBangumiList(final List<Bangumi> bangumis) {
    return SliverPadding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
      sliver: SliverWaterfallFlow(
        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          crossAxisCount: 3,
          collectGarbage: (List<int> garbages) {
            garbages.forEach(
                (index) => CachedNetworkImageProvider(bangumis[index].cover));
          },
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _buildBangumiItem(context, bangumis[index], index);
          },
          childCount: bangumis.length,
        ),
      ),
    );
  }

  Widget _buildBangumiItem(
    final BuildContext context,
    final Bangumi bangumi,
    final int index,
  ) {
    final String currFlag = "bangumi:${bangumi.id}:${bangumi.cover}";
    return Selector<IndexModel, String>(
      builder: (context, tapScaleFlag, child) {
        Matrix4 transform;
        if (tapScaleFlag == currFlag) {
          transform = Matrix4.diagonal3Values(0.9, 0.9, 1);
        } else {
          transform = Matrix4.identity();
        }
        final Widget cover =
        _buildBangumiListItemCover(currFlag, bangumi, index);
        // final Color tagBgColor = Theme.of(context).primaryColor.withOpacity(0.87);
        // final Color tagColor = tagBgColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AnimatedTapContainer(
              transform: transform,
              onTapStart: () =>
              context
                  .read<IndexModel>()
                  .tapBangumiListItemFlag = currFlag,
              onTapEnd: () =>
              context
                  .read<IndexModel>()
                  .tapBangumiListItemFlag = null,
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
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.0)),
                child: Stack(
                  overflow: Overflow.clip,
                  children: [
                    Tooltip(
                      padding:
                      EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                      showDuration: Duration(seconds: 3),
                      message: bangumi.name + "\n" + bangumi.updateAt,
                      child: cover,
                    ),
                    if (bangumi.num > 0)
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
                              bangumi.num > 99 ? "99+" : "+${bangumi.num}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      child: bangumi.subscribed
                          ? SizedBox(
                              width: 24.0,
                              height: 24.0,
                              child: IconButton(
                                tooltip: "取消订阅",
                                padding: EdgeInsets.all(2.0),
                                icon: Icon(
                                  AntIcons.heart,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  context
                                      .read<IndexModel>()
                                      .subscribeBangumi(bangumi);
                                },
                              ),
                            )
                          : Container(
                              width: 24.0,
                              height: 24.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.black38,
                              ),
                              child: IconButton(
                                tooltip: "订阅",
                                padding: EdgeInsets.all(2.0),
                                iconSize: 16.0,
                                icon: Icon(
                                  AntIcons.heart_outline,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  context
                                      .read<IndexModel>()
                                      .subscribeBangumi(bangumi);
                                },
                              ),
                      ),
                    ),
                    // Positioned(
                    //   child: Container(
                    //     width: 24,
                    //     height: 24,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(12.0),
                    //       color: tagBgColor,
                    //       border: Border.all(
                    //         color: Theme.of(context).scaffoldBackgroundColor,
                    //         width: 2.0,
                    //       ),
                    //     ),
                    //     child: Center(
                    //       child: Text(
                    //         bangumi.week,
                    //         style: TextStyle(
                    //           color: tagColor,
                    //           height: 1.25,
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 12.0,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    //   bottom: -2,
                    //   right: -2,
                    // ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Tooltip(
              padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
              showDuration: Duration(seconds: 3),
              message: bangumi.name + "\n" + bangumi.updateAt,
              child: Row(
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
                          bangumi.grey
                              ? Colors.grey
                              : Theme.of(context).accentColor,
                          Theme.of(context).accentColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      bangumi.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.0,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              bangumi.updateAt,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10.0,
                height: 1.25,
              ),
            )
          ],
        );
      },
      selector: (_, model) => model.tapBangumiListItemFlag,
      shouldRebuild: (pre, next) => pre != next,
    );
  }

  Widget _buildBangumiListItemCover(
    final String currFlag,
    final Bangumi bangumi,
    final int index,
  ) {
    return ExtendedImage(
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
          child = _buildScrollableBackgroundCover(value, bangumi);
        }
        return AspectRatio(
          aspectRatio: 1.0,
          child: Hero(
            tag: currFlag,
            child: child,
          ),
        );
      },
    );
  }

  ValueListenableBuilder<double> _buildScrollableBackgroundCover(
      ExtendedImageState state,
      Bangumi bangumi,) {
    return ValueListenableBuilder(
      valueListenable: scrollNotifier,
      builder: (BuildContext context, double scrolledOffset, Widget child) {
        final double itemPosition = itemHeight * bangumi.location.row +
            sectionHeight * bangumi.location.srow;
        final double align = ((scrolledOffset + wrapperHeight - itemPosition) /
            (wrapperHeight - itemHeight / 2))
            .clamp(0.0, 1.0) *
            2 -
            1;
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 8.0,
                color: Colors.black.withAlpha(24),
              )
            ],
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            image: DecorationImage(
              image: state.imageProvider,
              fit: BoxFit.cover,
              alignment: Alignment(align, align),
              colorFilter: bangumi.grey
                  ? ColorFilter.mode(Colors.grey, BlendMode.color)
                  : null,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBangumiList(bangumis);
  }
}
