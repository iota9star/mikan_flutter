import 'dart:math' as Math;
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';

typedef HandleSubscribe = void Function(Bangumi bangumi, String flag);

@immutable
class BangumiSliverGridFragment extends StatelessWidget {
  final String? flag;
  final List<Bangumi> bangumis;
  final EdgeInsetsGeometry padding;
  final HandleSubscribe handleSubscribe;

  BangumiSliverGridFragment({
    Key? key,
    this.flag,
    required this.bangumis,
    required this.handleSubscribe,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return _buildBangumiList(theme, bangumis);
  }

  Widget _buildBangumiList(
    final ThemeData theme,
    final List<Bangumi> bangumis,
  ) {
    return SliverPadding(
      padding: this.padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 210.0,
          maxCrossAxisExtent: 120.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _buildBangumiItem(
              context,
              theme,
              index,
              bangumis[index],
            );
          },
          childCount: bangumis.length,
        ),
      ),
    );
  }

  Widget _buildBangumiItem(
    final BuildContext context,
    final ThemeData theme,
    final int index,
    final Bangumi bangumi,
  ) {
    final String currFlag =
        "$flag:bangumi:$index:${bangumi.id}:${bangumi.cover}";
    final String msg = [bangumi.name, bangumi.updateAt]
        .where((element) => element.isNotBlank)
        .join("\n");
    final Widget cover = _buildBangumiItemCover(currFlag, bangumi);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: TapScaleContainer(
            width: double.infinity,
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
                clipBehavior: Clip.antiAlias,
                fit: StackFit.expand,
                children: [
                  Positioned.fill(child: cover),
                  if (bangumi.num != null && bangumi.num! > 0)
                    Positioned(
                      right: -10,
                      top: 4,
                      child: Transform.rotate(
                        angle: Math.pi / 4.0,
                        child: Container(
                          width: 42.0,
                          color: Colors.redAccent,
                          child: Text(
                            bangumi.num! > 99 ? "99+" : "+${bangumi.num}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              wordSpacing: 1.0,
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
        ),
        SizedBox(height: 10.0),
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
                      bangumi.grey == true ? Colors.grey : theme.accentColor,
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
  }

  Widget _buildSubscribeButton(final Bangumi bangumi, final String currFlag) {
    final Widget child = bangumi.subscribed
        ? SizedBox(
            width: 28.0,
            height: 28.0,
            child: IconButton(
              tooltip: "取消订阅",
              padding: EdgeInsets.all(4.0),
              iconSize: 20.0,
              icon: Icon(
                FluentIcons.heart_24_filled,
                color: Colors.redAccent,
              ),
              onPressed: () {
                this.handleSubscribe.call(bangumi, currFlag);
              },
            ),
          )
        : SizedBox(
            width: 28.0,
            height: 28.0,
            child: IconButton(
              tooltip: "订阅",
              padding: EdgeInsets.all(4.0),
              iconSize: 20.0,
              icon: Icon(
                FluentIcons.heart_24_regular,
                color: Colors.blueGrey,
              ),
              onPressed: () {
                this.handleSubscribe.call(bangumi, currFlag);
              },
            ),
          );
    return Positioned(
      child: child,
    );
  }

  Widget _buildBangumiItemCover(
    final String currFlag,
    final Bangumi bangumi,
  ) {
    return ExtendedImage.network(
      bangumi.cover,
      loadStateChanged: (state) {
        Widget child;
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            child = _buildBangumiItemPlaceholder();
            break;
          case LoadState.completed:
            child = _buildBackgroundCover(
              bangumi,
              state.imageProvider,
            );
            break;
          case LoadState.failed:
            child = _buildBangumiItemError();
            break;
        }
        return Hero(
          tag: currFlag,
          child: child,
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

  Widget _buildBackgroundCover(
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
