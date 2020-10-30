import 'dart:math' as Math;

import 'package:ant_icons/ant_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class BangumiGridFragment extends StatelessWidget {
  final List<BangumiRow> bangumiRows;
  final ValueNotifier<double> scrollNotifier;

  const BangumiGridFragment({Key key, this.bangumiRows, this.scrollNotifier})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _buildBangumiSubgroupItemWrapper(
            context,
            bangumiRows,
            index,
          );
        },
        childCount: bangumiRows.length,
      ),
    );
  }

  Widget _buildBangumiSubgroupItemWrapper(
    final BuildContext context,
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
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: 8.0,
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
          child: _buildBangumiList(bangumiRow),
          margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
        )
      ],
    );
  }

  Widget _buildBangumiList(final BangumiRow row) {
    return WaterfallFlow.builder(
      padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0, bottom: 16.0),
      itemCount: row.bangumis.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        crossAxisCount: 3,
        collectGarbage: (List<int> garbages) {
          garbages.forEach(
              (index) => CachedNetworkImageProvider(row.bangumis[index].cover));
        },
      ),
      itemBuilder: (context, index) {
        return _buildBangumiItem(context, row.bangumis[index], index);
      },
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
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
          final double align = 0;
          child = _buildScrollableBackgroundCover(align, value, bangumi);
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

  ValueListenableBuilder<double> _buildScrollableBackgroundCover(double align,
      ExtendedImageState state,
      Bangumi bangumi,) {
    return ValueListenableBuilder(
      valueListenable: scrollNotifier,
      builder: (BuildContext context, double scrolledOffset, Widget child) {
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
}
