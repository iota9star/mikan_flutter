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
    return SliverPadding(
      padding: edgeH24B16,
      sliver: ValueListenableBuilder(
        valueListenable: MyHive.settings.listenable(
          keys: [SettingsHiveKey.cardRatio],
        ),
        builder: (context, _, child) {
          final cardRatio = MyHive.getCardRatio();
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              crossAxisSpacing: context.margins,
              mainAxisSpacing: context.margins,
              maxCrossAxisExtent: 240.0,
              childAspectRatio: cardRatio,
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
          );
        },
      ),
    );
  }

  Widget _buildBangumiItem(
    BuildContext context,
    ThemeData theme,
    int index,
    Bangumi bangumi,
  ) {
    final currFlag = '$flag:bangumi:$index:${bangumi.id}:${bangumi.cover}';
    final cover = _buildBangumiItemCover(currFlag, bangumi);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                        top: 12.0,
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
                    style: theme.textTheme.titleMedium,
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
    String currFlag,
    Bangumi bangumi,
  ) {
    final provider = CacheImage(bangumi.cover);
    return Image(
      image: provider,
      isAntiAlias: true,
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
          'assets/mikan.png',
        ),
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

  Widget _buildBackgroundCover(
    Bangumi bangumi,
    ImageProvider imageProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius12,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
          colorFilter: bangumi.grey
              ? const ColorFilter.mode(Colors.grey, BlendMode.color)
              : null,
        ),
      ),
    );
  }
}
