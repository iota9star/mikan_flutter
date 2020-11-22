import 'dart:math' as Math;
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@immutable
class BangumiSliverGridFragment extends StatelessWidget {
  final String flag;
  final List<Bangumi> bangumis;

  BangumiSliverGridFragment({
    Key key,
    this.bangumis,
    this.flag,
  }) : super(key: key);

  final double wrapperHeight = Sz.screenHeight / 2;
  final double sectionHeight = 57;
  final double itemHeight = (Sz.screenWidth - 32 - 32) / 3 + 40 + 16;

  @override
  Widget build(BuildContext context) {
    return _buildBangumiList(context, bangumis);
  }

  Widget _buildBangumiList(
    final BuildContext context,
    final List<Bangumi> bangumis,
  ) {
    final Color accentColor = Theme.of(context).accentColor;
    final Color backgroundColor = Theme.of(context).backgroundColor;
    return SliverPadding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
      sliver: SliverWaterfallFlow(
        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          crossAxisCount: 3,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _buildBangumiItem(
              accentColor,
              backgroundColor,
              bangumis[index],
              index,
            );
          },
          childCount: bangumis.length,
        ),
      ),
    );
  }

  Widget _buildBangumiItem(
    final Color accentColor,
    final Color backgroundColor,
    final Bangumi bangumi,
    final int index,
  ) {
    final String currFlag =
        "$flag:bangumi:$index:${bangumi.id}:${bangumi.cover}";
    final String msg = [bangumi.name, bangumi.updateAt]
        .where((element) => element.isNotBlank)
        .join("\n");
    return Selector<IndexModel, String>(
      selector: (_, model) => model.tapBangumiListItemFlag,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, tapScaleFlag, child) {
        final Matrix4 transform = tapScaleFlag == currFlag
            ? Matrix4.diagonal3Values(0.9, 0.9, 1)
            : Matrix4.identity();
        final Widget cover = _buildBangumiItemCover(
          backgroundColor,
          currFlag,
          bangumi,
        );
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
                if (bangumi.grey == true) {
                  "此番组下暂无作品".toast();
                } else {
                  Navigator.pushNamed(
                    context,
                    Routes.bangumi.name,
                    arguments: Routes.bangumi.d(
                      heroTag: currFlag,
                      bangumiId: bangumi.id,
                      cover: bangumi.cover,
                    ),
                  );
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                ),
                child: Stack(
                  overflow: Overflow.clip,
                  children: [
                    Tooltip(
                      padding: EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 8.0,
                      ),
                      showDuration: Duration(seconds: 3),
                      message: msg,
                      child: cover,
                    ),
                    if (bangumi.num != null && bangumi.num > 0)
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
                                  FluentIcons.heart_24_filled,
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
                                  FluentIcons.heart_24_regular,
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
              message: msg,
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
                          bangumi.grey == true ? Colors.grey : accentColor,
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
            if (bangumi.updateAt.isNotBlank)
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
    );
  }

  Widget _buildBangumiItemCover(
    final Color backgroundColor,
    final String currFlag,
    final Bangumi bangumi,
  ) {
    return ExtendedImage.network(
      bangumi.cover,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      clearMemoryCacheWhenDispose: true,
      loadStateChanged: (state) {
        Widget child;
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            child = _buildBangumiItemPlaceholder(backgroundColor);
            break;
          case LoadState.completed:
            child = _buildScrollableBackgroundCover(
              backgroundColor,
              bangumi,
              state.imageProvider,
            );
            break;
          case LoadState.failed:
            child = _buildBangumiItemError(backgroundColor);
            break;
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

  Widget _buildBangumiItemPlaceholder(final Color backgroundColor) {
    return Container(
      padding: EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 8.0,
            color: Colors.black.withAlpha(24),
          ),
        ],
      ),
      child: Center(
        child: ExtendedImage.asset(
          "assets/mikan.png",
        ),
      ),
    );
  }

  Widget _buildBangumiItemError(final Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 8.0,
            color: Colors.black.withAlpha(24),
          )
        ],
        color: backgroundColor,
        image: DecorationImage(
          image: ExtendedAssetImageProvider("assets/mikan.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
        ),
      ),
    );
  }

  Widget _buildScrollableBackgroundCover(
    final Color backgroundColor,
    final Bangumi bangumi,
    final ImageProvider imageProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 8.0,
            color: Colors.black.withAlpha(24),
          )
        ],
        color: backgroundColor,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
          colorFilter: bangumi.grey == true
              ? ColorFilter.mode(Colors.grey, BlendMode.color)
              : null,
        ),
      ),
    );
  }
}
