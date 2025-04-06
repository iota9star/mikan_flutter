import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/extension.dart';
import '../../internal/image_provider.dart';
import '../../internal/kit.dart';
import '../../providers/bangumi_model.dart';
import '../../res/assets.gen.dart';
import '../../topvars.dart';
import '../../widget/bottom_sheet.dart';
import '../../widget/icon_button.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/scalable_tap.dart';
import '../components/simple_record_item.dart';
import '../fragments/subgroup_bangumis.dart';
import '../fragments/subgroup_subscribe.dart';

@immutable
class BangumiPage extends StatelessWidget {
  BangumiPage({
    super.key,
    required this.bangumiId,
    required this.cover,
    this.name,
  });

  final String bangumiId;
  final String cover;
  final String? name;

  final ValueNotifier<double> _scrollRatio = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerBackgroundColor = ColorTween(
      begin: theme.colorScheme.surface.withValues(alpha: 0.0),
      end: theme.colorScheme.surface,
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
                            border: ratio > 0.1
                                ? Border(
                                    bottom: Divider.createBorderSide(
                                      context,
                                      color: theme.colorScheme.outlineVariant,
                                      width: 0.0,
                                    ),
                                  )
                                : null,
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
                                  child: name == null
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
                                          name!,
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
            subList.addAll(
              [
                sizedBoxH24,
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.value.name,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    sizedBoxW8,
                    if (!e.value.rss.isNullOrBlank)
                      ElevatedButton(
                        onPressed: () {
                          e.value.rss.copy();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(32.0, 32.0),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          shape: const RoundedRectangleBorder(
                            borderRadius: borderRadius6,
                          ),
                        ),
                        child: e.value.subscribed
                            ? Row(
                                children: [
                                  const Icon(Icons.rss_feed_rounded),
                                  sizedBoxW4,
                                  Text(e.value.sublang!),
                                ],
                              )
                            : const Icon(Icons.rss_feed_rounded),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SimpleRecordItem(
                      record: e.value.records[index],
                    ),
                  ),
              ],
            );
            subTags.add(
              Tooltip(
                message: e.value.name,
                child: RippleTap(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: borderRadius6,
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
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        final scale = (64.0 + context.screenWidth) / context.screenWidth;
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
                          theme.colorScheme.surface.withValues(alpha: 0.64),
                          theme.colorScheme.surface,
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
                        child: SelectionArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Tooltip(
                                message: detail.name,
                                child: AutoSizeText(
                                  '${detail.name}\n',
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(color: theme.secondary),
                                  maxLines: 3,
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
                                      ),
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
                        ),
                      )
                    else if (name != null)
                      Expanded(
                        child: Tooltip(
                          message: name,
                          child: AutoSizeText(
                            '$name\n',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: theme.secondary),
                            maxLines: 3,
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
              color: theme.colorScheme.surface,
              height: 36.0,
            ),
          ),
          if (subTags.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '字幕组',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    MBottomSheet.show(
                      context,
                      (context) => MBottomSheet(
                        heightFactor: 0.78,
                        child: SubgroupSubscribe(model),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0.0, 32.0),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: borderRadius6,
                    ),
                  ),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('订阅管理'),
                ),
              ],
            ),
            sizedBoxH8,
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
            SelectionArea(
              child: Text(
                detail.intro,
                textAlign: TextAlign.justify,
                softWrap: true,
                style: theme.textTheme.bodyLarge,
              ),
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
                  child: Container(
                    padding: edge28,
                    child: Center(
                      child: Assets.mikan.image(),
                    ),
                  ),
                );
        },
        errorBuilder: (_, __, ___) {
          return AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Assets.mikan.provider(),
                  fit: BoxFit.cover,
                  colorFilter:
                      const ColorFilter.mode(Colors.grey, BlendMode.color),
                ),
              ),
            ),
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
