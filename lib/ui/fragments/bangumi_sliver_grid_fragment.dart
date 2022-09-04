import 'dart:math' as math;

import 'package:extended_image/extended_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/providers/op_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';
import 'package:provider/provider.dart';

typedef HandleSubscribe = void Function(Bangumi bangumi, String flag);

@immutable
class BangumiSliverGridFragment extends StatelessWidget {
  final String? flag;
  final List<Bangumi> bangumis;
  final EdgeInsetsGeometry padding;
  final HandleSubscribe handleSubscribe;

  const BangumiSliverGridFragment({
    Key? key,
    this.flag,
    required this.bangumis,
    required this.handleSubscribe,
    this.padding = edge16,
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
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          maxCrossAxisExtent: 156.0,
          childAspectRatio: 0.56,
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
              borderRadius: borderRadius8,
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withOpacity(0.08),
                )
              ],
              color: theme.backgroundColor,
            ),
            onTap: () {
              if (bangumi.grey) {
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
              borderRadius: borderRadius8,
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
                        angle: math.pi / 4.0,
                        child: Container(
                          width: 42.0,
                          color: Colors.redAccent,
                          child: Text(
                            bangumi.num! > 99 ? "99+" : "+${bangumi.num}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!bangumi.grey)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: _buildSubscribeButton(bangumi, currFlag),
                    ),
                ],
              ),
            ),
          ),
        ),
        sizedBoxH10,
        Tooltip(
          padding: edgeH8V6,
          showDuration: dur3000,
          message: msg,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 4,
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bangumi.grey == true ? Colors.grey : theme.secondary,
                      theme.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: borderRadius2,
                ),
              ),
              sizedBoxW4,
              Expanded(
                child: Text(
                  bangumi.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle16B500,
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
              fontSize: 12.0,
              height: 1.25,
              color: theme.textTheme.subtitle1?.color,
            ),
          )
      ],
    );
  }

  Widget _buildSubscribeButton(final Bangumi bangumi, final String currFlag) {
    return Selector<OpModel, String>(
      selector: (_, model) => model.flag,
      shouldRebuild: (_, next) => next == currFlag,
      builder: (_, __, ___) {
        return bangumi.subscribed
            ? SizedBox(
                width: 32.0,
                height: 32.0,
                child: IconButton(
                  tooltip: "取消订阅",
                  padding: edge4,
                  iconSize: 24.0,
                  icon: const Icon(
                    FluentIcons.heart_24_filled,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    handleSubscribe.call(bangumi, currFlag);
                  },
                ),
              )
            : SizedBox(
                width: 32.0,
                height: 32.0,
                child: IconButton(
                  tooltip: "订阅",
                  padding: edge4,
                  iconSize: 24.0,
                  icon: Icon(
                    FluentIcons.heart_24_regular,
                    color: Colors.redAccent.shade100,
                  ),
                  onPressed: () {
                    handleSubscribe.call(bangumi, currFlag);
                  },
                ),
              );
      },
    );
  }

  Widget _buildBangumiItemCover(
    final String currFlag,
    final Bangumi bangumi,
  ) {
    return ExtendedImage(
      image: CacheImageProvider(bangumi.cover),
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
      padding: edge28,
      child: Center(
        child: ExtendedImage.asset(
          "assets/mikan.png",
        ),
      ),
    );
  }

  Widget _buildBangumiItemError() {
    return Container(
      decoration: const BoxDecoration(
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
              ? const ColorFilter.mode(Colors.grey, BlendMode.color)
              : null,
        ),
      ),
    );
  }
}
