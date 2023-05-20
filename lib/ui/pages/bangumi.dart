import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/extension.dart';
import '../../internal/image_provider.dart';
import '../../internal/kit.dart';
import '../../mikan_routes.dart';
import '../../providers/bangumi_model.dart';
import '../../topvars.dart';
import '../../widget/bottom_sheet.dart';
import '../../widget/icon_button.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/scalable_tap.dart';
import '../fragments/subgroup_bangumis.dart';

@FFRoute(name: '/bangumi')
@immutable
class BangumiPage extends StatelessWidget {
  BangumiPage({
    super.key,
    required this.bangumiId,
    required this.cover,
    required this.heroTag,
    this.title,
  });

  final String heroTag;
  final String bangumiId;
  final String cover;
  final String? title;

  final ValueNotifier<double> _scrollRatio = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerBackgroundColor = ColorTween(
      begin: theme.colorScheme.background.withOpacity(0.0),
      end: theme.colorScheme.background,
    );
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider<BangumiModel>(
        create: (_) => BangumiModel(bangumiId, cover),
        child: Builder(
          builder: (context) {
            final model = Provider.of<BangumiModel>(context, listen: false);
            return Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: NotificationListener<ScrollUpdateNotification>(
                      onNotification: (ScrollUpdateNotification notification) {
                        final double offset = notification.metrics.pixels;
                        if (offset >= 0) {
                          _scrollRatio.value = math.min(1.0, offset / 96.0);
                        }
                        return true;
                      },
                      child: _buildBody(context, theme, model),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _scrollRatio,
                      builder: (_, ratio, __) {
                        final bgc = headerBackgroundColor.transform(ratio);
                        return Container(
                          decoration: BoxDecoration(
                            color: bgc,
                            border: Border(
                              bottom: BorderSide(
                                color: ratio >= 0.99
                                    ? theme.colorScheme.surfaceVariant
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.only(
                            top: 12.0 + context.statusBarHeight,
                            left: 12.0,
                            right: 12.0,
                            bottom: 8.0,
                          ),
                          child: Row(
                            children: [
                              const BackIconButton(),
                              sizedBoxW16,
                              if (ratio > 0.88)
                                Expanded(
                                  child: title == null
                                      ? Selector<BangumiModel, String?>(
                                          selector: (_, model) =>
                                              model.bangumiDetail?.name,
                                          shouldRebuild: (pre, next) =>
                                              pre != next,
                                          builder: (_, value, __) {
                                            if (value == null) {
                                              return sizedBox;
                                            }
                                            return Text(
                                              value,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleLarge,
                                            );
                                          },
                                        )
                                      : Text(
                                          title!,
                                          style: theme.textTheme.titleLarge,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                )
                              else
                                spacer,
                              sizedBoxW16,
                              IconButton(
                                onPressed: () {
                                  model.bangumiDetail?.share.share();
                                },
                                icon: const Icon(Icons.share_rounded),
                              ),
                              IconButton(
                                onPressed: model.changeSubscribe,
                                icon: Selector<BangumiModel, bool>(
                                  selector: (_, model) =>
                                      model.bangumiDetail?.subscribed ?? false,
                                  shouldRebuild: (pre, next) => pre != next,
                                  builder: (_, subscribed, __) {
                                    return Icon(
                                      subscribed
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color:
                                          subscribed ? theme.secondary : null,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    BangumiModel model,
  ) {
    final accentTagStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.secondary.isDark ? Colors.white : Colors.black,
    );
    final primaryTagStyle = accentTagStyle?.copyWith(
      color: theme.primary.isDark ? Colors.white : Colors.black,
    );
    final safeArea = MediaQuery.of(context).padding;
    return Selector<BangumiModel, int>(
      selector: (_, model) => model.refreshFlag,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, _, __) {
        final detail = model.bangumiDetail;
        final notNull = detail != null;
        final subgroups = detail?.subgroupBangumis.entries;
        final List<Widget> subTags = [];
        final List<Widget> subList = [];
        if (subgroups != null) {
          for (final e in subgroups) {
            final length = e.value.records.length;
            final maxItemLen = length > 4 ? 4 : length;
            subList.addAll([
              sizedBoxH24,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      e.value.name,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(12.0, 0.0),
                    child: IconButton(
                      onPressed: () {
                        _showSubgroupPanel(context, model, e.value.dataId);
                      },
                      icon: const Icon(Icons.east_rounded),
                    ),
                  ),
                ],
              ),
              sizedBoxH12,
              for (int index = 0; index < maxItemLen; index++)
                () {
                  final record = e.value.records[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ScalableCard(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.record.name,
                          arguments: Routes.record.d(url: record.url),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              record.title,
                              style: theme.textTheme.bodyMedium,
                            ),
                            sizedBoxH12,
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        runSpacing: 4.0,
                                        spacing: 4.0,
                                        children: [
                                          if (record.size.isNotBlank)
                                            Container(
                                              padding: edgeH4V2,
                                              decoration: BoxDecoration(
                                                color: theme.secondary,
                                                borderRadius: borderRadius4,
                                              ),
                                              child: Text(
                                                record.size,
                                                style: accentTagStyle,
                                              ),
                                            ),
                                          if (!record.tags.isNullOrEmpty)
                                            ...List.generate(
                                              record.tags.length,
                                              (index) {
                                                return Container(
                                                  padding: edgeH4V2,
                                                  decoration: BoxDecoration(
                                                    color: theme.primary,
                                                    borderRadius: borderRadius4,
                                                  ),
                                                  child: Text(
                                                    record.tags[index],
                                                    style: primaryTagStyle,
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                                      sizedBoxH4,
                                      Text(
                                        record.publishAt,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                sizedBoxW8,
                                TMSMenuButton(
                                  torrent: record.torrent,
                                  magnet: record.magnet,
                                  share: record.share,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }()
            ]);
            subTags.add(
              Tooltip(
                message: e.value.name,
                child: RippleTap(
                  color: theme.secondary.withOpacity(0.1),
                  borderRadius: borderRadius8,
                  onTap: () {
                    _showSubgroupPanel(context, model, e.key);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      e.value.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                ),
              ),
            );
          }
        }

        final scale = (50.0 + context.screenWidth) / context.screenWidth;
        final items = [
          Stack(
            children: [
              Positioned.fill(
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: CacheImage(cover),
                        alignment: Alignment.topCenter,
                        isAntiAlias: true,
                      ),
                    ),
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.background.withOpacity(0.72),
                          theme.colorScheme.background,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.56],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 120.0 + context.statusBarHeight,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: _buildCover(cover),
                    ),
                    sizedBoxW16,
                    if (detail != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Tooltip(
                              message: detail.name,
                              child: AutoSizeText(
                                '${detail.name}\n',
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(color: theme.secondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            sizedBoxH4,
                            ...detail.more.entries.mapIndexed((index, e) {
                              final child = Row(
                                children: [
                                  Text(
                                    '${e.key}：',
                                    softWrap: true,
                                    style: theme.textTheme.labelLarge,
                                  ),
                                  if (e.value.startsWith('http'))
                                    RippleTap(
                                      onTap: () {
                                        e.value.launchAppAndCopy();
                                      },
                                      child: Text(
                                        '打开链接',
                                        softWrap: true,
                                        style: theme.textTheme.labelLarge,
                                      ),
                                    )
                                  else
                                    Text(
                                      e.value,
                                      softWrap: true,
                                      style: theme.textTheme.labelLarge,
                                    )
                                ],
                              );
                              return index == detail.more.length - 1
                                  ? child
                                  : Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: child,
                                    );
                            }),
                          ],
                        ),
                      )
                    else if (title != null)
                      Expanded(
                        child: Tooltip(
                          message: title,
                          child: AutoSizeText(
                            '$title\n',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: theme.secondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Transform.scale(
            scale: scale,
            child: Container(
              color: theme.colorScheme.background,
              height: 36.0,
            ),
          ),
          if (subTags.isNotEmpty) ...[
            Text(
              '字幕组',
              style: theme.textTheme.titleLarge,
            ),
            sizedBoxH12,
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: subTags,
            ),
          ],
          if (notNull && detail.intro.isNotBlank) ...[
            sizedBoxH24,
            Text(
              '概况简介',
              style: theme.textTheme.titleLarge,
            ),
            sizedBoxH12,
            Text(
              detail.intro,
              textAlign: TextAlign.justify,
              softWrap: true,
              style: theme.textTheme.bodyLarge,
            ),
          ],
          ...subList,
        ];
        return Container(
          constraints: const BoxConstraints(maxWidth: 640.0),
          child: EasyRefresh(
            onRefresh: model.load,
            refreshOnStart: true,
            header: defaultHeader,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return items[index];
              },
              itemCount: items.length,
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: safeArea.bottom + 36.0,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCover(String cover) {
    return ScalableCard(
      onTap: () {},
      child: Image(
        image: CacheImage(cover),
        width: 148.0,
        loadingBuilder: (_, child, event) {
          return event == null
              ? child
              : AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Hero(
                    tag: heroTag,
                    child: Container(
                      padding: edge28,
                      child: Center(
                        child: Image.asset(
                          'assets/mikan.png',
                        ),
                      ),
                    ),
                  ),
                );
        },
        errorBuilder: (_, __, ___) {
          return AspectRatio(
            aspectRatio: 3 / 4,
            child: Hero(
              tag: heroTag,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/mikan.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
                  ),
                ),
              ),
            ),
          );
        },
        frameBuilder: (_, child, ___, ____) {
          return Hero(
            tag: heroTag,
            child: child,
          );
        },
      ),
    );
  }

  void _showSubgroupPanel(
    BuildContext context,
    BangumiModel model,
    String dataId,
  ) {
    MBottomSheet.show(
      context,
      (context) => MBottomSheet(
        heightFactor: 0.78,
        child: SubgroupBangumis(bangumiModel: model, dataId: dataId),
      ),
    );
  }
}
