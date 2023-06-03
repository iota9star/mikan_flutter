import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../internal/extension.dart';
import '../../internal/hive.dart';
import '../../internal/image_provider.dart';
import '../../internal/kit.dart';
import '../../mikan_routes.dart';
import '../../model/bangumi.dart';
import '../../providers/op_model.dart';
import '../../topvars.dart';
import '../../widget/scalable_tap.dart';

typedef HandleSubscribe = void Function(Bangumi bangumi, String flag);

@immutable
class BangumiSliverGridFragment extends StatelessWidget {
  const BangumiSliverGridFragment({
    super.key,
    this.flag,
    required this.bangumis,
    required this.handleSubscribe,
  });

  final String? flag;
  final List<Bangumi> bangumis;
  final HandleSubscribe handleSubscribe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final margins = context.margins;
    return SliverPadding(
      padding: edgeH24B16,
      sliver: ValueListenableBuilder(
        valueListenable: MyHive.settings.listenable(
          keys: [
            SettingsHiveKey.cardRatio,
            SettingsHiveKey.cardStyle,
            SettingsHiveKey.cardWidth,
          ],
        ),
        builder: (context, _, child) {
          final cardRatio = MyHive.getCardRatio().toDouble();
          final cardStyle = MyHive.getCardStyle();
          final cardWidth = MyHive.getCardWidth().toDouble();
          final build = cardStyle == 1
              ? _buildItemStyle1
              : cardStyle == 2
                  ? _buildItemStyle2
                  : cardStyle == 3
                      ? _buildItemStyle3
                      : cardStyle == 4
                          ? _buildItemStyle4
                          : _buildItemStyle1;
          final size = calcGridItemSizeWithMaxCrossAxisExtent(
            crossAxisExtent: context.screenWidth - 48.0,
            maxCrossAxisExtent: cardWidth,
            crossAxisSpacing: margins,
            childAspectRatio: cardRatio,
          );
          final imageWidth = (size.width * context.devicePixelRatio).ceil();
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              crossAxisSpacing: margins,
              mainAxisSpacing: margins,
              maxCrossAxisExtent: cardWidth,
              childAspectRatio: cardRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return build(
                  context,
                  theme,
                  imageWidth,
                  bangumis[index],
                );
              },
              childCount: bangumis.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemStyle4(
    BuildContext context,
    ThemeData theme,
    int imageWidth,
    Bangumi bangumi,
  ) {
    final currFlag = '$flag:bangumi:${bangumi.id}:${bangumi.cover}';
    final cover = _buildBangumiItemCover(imageWidth, currFlag, bangumi);
    return ScalableCard(
      onTap: () {
        if (bangumi.grey) {
          '此番组下暂无作品'.toast();
        } else {
          Navigator.pushNamed(
            context,
            Routes.bangumi.name,
            arguments: Routes.bangumi.d(
              heroTag: currFlag,
              bangumiId: bangumi.id,
              cover: bangumi.cover,
              title: bangumi.name,
            ),
          );
        }
      },
      child: Stack(
        children: [
          Positioned.fill(child: cover),
          if (bangumi.num != null && bangumi.num! > 0)
            PositionedDirectional(
              top: 14.0,
              end: 12.0,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: theme.colorScheme.error,
                  shape: const StadiumBorder(),
                ),
                padding: edgeH6V2,
                child: Text(
                  bangumi.num! > 99 ? '99+' : '+${bangumi.num}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onError,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            child: _buildSubscribeButton(theme, bangumi, currFlag),
          ),
        ],
      ),
    );
  }

  Widget _buildItemStyle3(
    BuildContext context,
    ThemeData theme,
    int imageWidth,
    Bangumi bangumi,
  ) {
    final currFlag = '$flag:bangumi:${bangumi.id}:${bangumi.cover}';
    final cover = Container(
      foregroundDecoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black87,
          ],
          stops: [0.68, 1.0],
        ),
      ),
      child: _buildBangumiItemCover(imageWidth, currFlag, bangumi),
    );
    return ScalableCard(
      onTap: () {
        if (bangumi.grey) {
          '此番组下暂无作品'.toast();
        } else {
          Navigator.pushNamed(
            context,
            Routes.bangumi.name,
            arguments: Routes.bangumi.d(
              heroTag: currFlag,
              bangumiId: bangumi.id,
              cover: bangumi.cover,
              title: bangumi.name,
            ),
          );
        }
      },
      child: Stack(
        children: [
          Positioned.fill(child: cover),
          if (bangumi.num != null && bangumi.num! > 0)
            PositionedDirectional(
              top: 14.0,
              end: 12.0,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: theme.colorScheme.error,
                  shape: const StadiumBorder(),
                ),
                padding: edgeH6V2,
                child: Text(
                  bangumi.num! > 99 ? '99+' : '+${bangumi.num}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onError,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            child: _buildSubscribeButton(theme, bangumi, currFlag),
          ),
          PositionedDirectional(
            bottom: 12.0,
            start: 12.0,
            end: 12.0,
            child: Column(
              children: [
                Text(
                  bangumi.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      theme.textTheme.titleSmall!.copyWith(color: Colors.white),
                ),
                if (bangumi.updateAt.isNotBlank)
                  Text(
                    bangumi.updateAt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!
                        .copyWith(color: Colors.white70),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemStyle2(
    BuildContext context,
    ThemeData theme,
    int imageWidth,
    Bangumi bangumi,
  ) {
    final currFlag = '$flag:bangumi:${bangumi.id}:${bangumi.cover}';
    final cover = _buildBangumiItemCover(imageWidth, currFlag, bangumi);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ScalableCard(
            onTap: () {
              if (bangumi.grey) {
                '此番组下暂无作品'.toast();
              } else {
                Navigator.pushNamed(
                  context,
                  Routes.bangumi.name,
                  arguments: Routes.bangumi.d(
                    heroTag: currFlag,
                    bangumiId: bangumi.id,
                    cover: bangumi.cover,
                    title: bangumi.name,
                  ),
                );
              }
            },
            child: bangumi.grey
                ? cover
                : Stack(
                    children: [
                      Positioned.fill(
                        child: cover,
                      ),
                      if (bangumi.num != null && bangumi.num! > 0)
                        PositionedDirectional(
                          top: 14.0,
                          end: 12.0,
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: theme.colorScheme.error,
                              shape: const StadiumBorder(),
                            ),
                            padding: edgeH6V2,
                            child: Text(
                              bangumi.num! > 99 ? '99+' : '+${bangumi.num}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onError,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                      PositionedDirectional(
                        child: _buildSubscribeButton(theme, bangumi, currFlag),
                      ),
                    ],
                  ),
          ),
        ),
        sizedBoxH8,
        Text(
          bangumi.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall,
        ),
        if (bangumi.updateAt.isNotBlank)
          Text(
            bangumi.updateAt,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        sizedBoxH8,
      ],
    );
  }

  Widget _buildItemStyle1(
    BuildContext context,
    ThemeData theme,
    int imageWidth,
    Bangumi bangumi,
  ) {
    final currFlag = '$flag:bangumi:${bangumi.id}:${bangumi.cover}';
    final cover = _buildBangumiItemCover(imageWidth, currFlag, bangumi);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ScalableCard(
            onTap: () {
              if (bangumi.grey) {
                '此番组下暂无作品'.toast();
              } else {
                Navigator.pushNamed(
                  context,
                  Routes.bangumi.name,
                  arguments: Routes.bangumi.d(
                    heroTag: currFlag,
                    bangumiId: bangumi.id,
                    cover: bangumi.cover,
                    title: bangumi.name,
                  ),
                );
              }
            },
            child: bangumi.grey || (bangumi.num == null || bangumi.num == 0)
                ? cover
                : Stack(
                    children: [
                      Positioned.fill(
                        child: cover,
                      ),
                      PositionedDirectional(
                        top: 14.0,
                        end: 12.0,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: theme.colorScheme.error,
                            shape: const StadiumBorder(),
                          ),
                          padding: edgeH6V2,
                          child: Text(
                            bangumi.num! > 99 ? '99+' : '+${bangumi.num}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onError,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        sizedBoxH8,
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bangumi.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  if (bangumi.updateAt.isNotBlank)
                    Text(
                      bangumi.updateAt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(8.0, 0.0),
              child: _buildSubscribeButton(theme, bangumi, currFlag),
            ),
          ],
        ),
        sizedBoxH8,
      ],
    );
  }

  Widget _buildSubscribeButton(
    ThemeData theme,
    Bangumi bangumi,
    String currFlag,
  ) {
    return bangumi.grey
        ? const IconButton(
            icon: Icon(Icons.favorite_border_rounded),
            onPressed: null,
          )
        : Selector<OpModel, String>(
            selector: (_, model) => model.flag,
            shouldRebuild: (_, next) => next == currFlag,
            builder: (_, __, ___) {
              return bangumi.subscribed
                  ? Tooltip(
                      message: '取消订阅',
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite_rounded,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () {
                          handleSubscribe.call(bangumi, currFlag);
                        },
                      ),
                    )
                  : Tooltip(
                      message: '订阅',
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite_border_rounded,
                          color: theme.colorScheme.error,
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
    int cacheWidth,
    String currFlag,
    Bangumi bangumi,
  ) {
    return Hero(
      tag: currFlag,
      child: FadeInImage(
        placeholder: const AssetImage('assets/mikan.png'),
        image: ResizeImage.resizeIfNeeded(
          cacheWidth,
          null,
          CacheImage(bangumi.cover),
        ),
        fit: BoxFit.cover,
        imageErrorBuilder: (_, __, ___) {
          return _buildBangumiItemError();
        },
      ),
    );
  }

  Widget _buildBangumiItemError() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/mikan.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
        ),
      ),
    );
  }
}

Size calcGridItemSizeWithMaxCrossAxisExtent({
  required double crossAxisExtent,
  required double maxCrossAxisExtent,
  required double crossAxisSpacing,
  required double childAspectRatio,
}) {
  int crossAxisCount =
      (crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing)).ceil();
  // Ensure a minimum count of 1, can be zero and result in an infinite extent
  // below when the window size is 0.
  crossAxisCount = math.max(1, crossAxisCount);
  final double usableCrossAxisExtent = math.max(
    0.0,
    crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
  );
  final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
  final double childMainAxisExtent = childCrossAxisExtent / childAspectRatio;
  return Size(childCrossAxisExtent, childMainAxisExtent);
}
