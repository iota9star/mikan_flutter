import 'dart:math' as Math;
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/providers/view_models/op_model.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

typedef HandleSubscribe = void Function(Bangumi bangumi, String flag);

@immutable
class BangumiSliverGridFragment extends StatelessWidget {
  final String flag;
  final List<Bangumi> bangumis;
  final EdgeInsetsGeometry padding;
  final HandleSubscribe handleSubscribe;

  BangumiSliverGridFragment({
    Key key,
    this.flag,
    @required this.bangumis,
    @required this.handleSubscribe,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final OpModel opModel = Provider.of<OpModel>(context, listen: false);
    return _buildBangumiList(theme, bangumis, opModel);
  }

  Widget _buildBangumiList(
    final ThemeData theme,
    final List<Bangumi> bangumis,
    final OpModel opModel,
  ) {
    return SliverPadding(
      padding: this.padding,
      sliver: SliverWaterfallFlow(
        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          crossAxisCount: 3,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, index) {
            return _buildBangumiItem(
              theme,
              index,
              bangumis[index],
              opModel,
            );
          },
          childCount: bangumis.length,
        ),
      ),
    );
  }

  Widget _buildBangumiItem(
    final ThemeData theme,
    final int index,
    final Bangumi bangumi,
    final OpModel opModel,
  ) {
    final String currFlag =
        "$flag:bangumi:$index:${bangumi.id}:${bangumi.cover}";
    final String msg = [bangumi.name, bangumi.updateAt]
        .where((element) => element.isNotBlank)
        .join("\n");
    return Selector<OpModel, String>(
      selector: (_, model) => model.rebuildFlag,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, tapFlag, child) {
        final Matrix4 transform = tapFlag == currFlag
            ? Matrix4.diagonal3Values(0.9, 0.9, 1)
            : Matrix4.identity();
        final Widget cover = _buildBangumiItemCover(currFlag, bangumi);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedTapContainer(
              transform: transform,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8.0,
                    color: Colors.black.withOpacity(0.08),
                  )
                ],
                color: theme.backgroundColor,
              ),
              onTapStart: () => opModel.rebuildFlag = currFlag,
              onTapEnd: () => opModel.rebuildFlag = null,
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
                borderRadius: BorderRadius.circular(8.0),
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
                    _buildSubscribeButton(bangumi, currFlag),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 12.0,
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
                          bangumi.grey == true
                              ? Colors.grey
                              : theme.accentColor,
                          theme.accentColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2.0),
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

  Widget _buildSubscribeButton(final Bangumi bangumi, final String currFlag) {
    return Positioned(
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
                  this.handleSubscribe?.call(bangumi, currFlag);
                },
              ),
            )
          : Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
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
                  this.handleSubscribe?.call(bangumi, currFlag);
                },
              ),
            ),
    );
  }

  Widget _buildBangumiItemCover(
    final String currFlag,
    final Bangumi bangumi,
  ) {
    return ExtendedImage.network(
      bangumi.cover,
      clearMemoryCacheWhenDispose: true,
      loadStateChanged: (state) {
        Widget child;
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            child = _buildBangumiItemPlaceholder();
            break;
          case LoadState.completed:
            child = _buildScrollableBackgroundCover(
              bangumi,
              state.imageProvider,
            );
            break;
          case LoadState.failed:
            child = _buildBangumiItemError();
            break;
        }
        return AspectRatio(
          aspectRatio: 3 / 4,
          child: Hero(
            tag: currFlag,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildBangumiItemPlaceholder() {
    return Container(
      padding: EdgeInsets.all(28.0),
      child: Center(
        child: ExtendedImage.asset(
          "assets/mikan.png",
        ),
      ),
    );
  }

  Widget _buildBangumiItemError() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ExtendedAssetImageProvider("assets/mikan.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
        ),
      ),
    );
  }

  Widget _buildScrollableBackgroundCover(
    final Bangumi bangumi,
    final ImageProvider imageProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
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
