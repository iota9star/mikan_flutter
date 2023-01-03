import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/providers/op_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';
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
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
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
    final currFlag = "$flag:bangumi:$index:${bangumi.id}:${bangumi.cover}";
    final msg = [bangumi.name, bangumi.updateAt]
        .where((element) => element.isNotBlank)
        .join("\n");
    final cover = _buildBangumiItemCover(currFlag, bangumi);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ScalableRippleTap(
            color: theme.backgroundColor,
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
                            fontWeight: FontWeight.w700,
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
        sizedBoxH8,
        Tooltip(
          padding: edgeH8V6,
          showDuration: dur3000,
          message: msg,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 4.0,
                height: 12.0,
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
                  style: textStyle15B500,
                ),
              ),
            ],
          ),
        ),
        if (bangumi.updateAt.isNotBlank)
          Text(
            bangumi.updateAt,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.caption,
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
            ? Tooltip(
                message: "取消订阅",
                child: RippleTap(
                  shape: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.redAccent,
                      size: 24.0,
                    ),
                  ),
                  onTap: () {
                    handleSubscribe.call(bangumi, currFlag);
                  },
                ),
              )
            : Tooltip(
                message: "订阅",
                child: RippleTap(
                  shape: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.redAccent,
                      size: 24.0,
                    ),
                  ),
                  onTap: () {
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
    final provider = CacheImageProvider(bangumi.cover);
    return Image(
      image: provider,
      loadingBuilder: (_, child, event) {
        return Hero(
          tag: currFlag,
          child: event == null ? child : _buildBangumiItemPlaceholder(),
        );
      },
      errorBuilder: (_, __, ___) {
        return Hero(
          tag: currFlag,
          child: _buildBangumiItemError(),
        );
      },
      frameBuilder: (_, __, ___, ____) {
        return _buildBackgroundCover(
          bangumi,
          provider,
        );
      },
    );
  }

  Widget _buildBangumiItemPlaceholder() {
    return Container(
      padding: edge28,
      child: Center(
        child: Image.asset(
          "assets/mikan.png",
        ),
      ),
    );
  }

  Widget _buildBangumiItemError() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/mikan.png"),
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
