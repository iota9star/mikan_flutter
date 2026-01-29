import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../mikan_api.dart';
import '../../../../../res/assets.gen.dart';
import '../../../../../shared/internal/extension.dart';
import '../../../../../shared/internal/image_provider.dart';
import '../../../../../shared/internal/kit.dart';
import '../../../../../shared/models/bangumi_details.dart';
import '../../../../../shared/models/subgroup_bangumi.dart';
import '../../../../../shared/services/subscription_service.dart' show subscribeBangumi, subscribeMutation;
import '../../../../../shared/ui/components/simple_record_item.dart';
import '../../../../../shared/ui/fragments/subgroup_bangumis.dart';
import '../../../../../shared/ui/fragments/subgroup_subscribe.dart';
import '../../../../../shared/widgets/bottom_sheet.dart';
import '../../../../../shared/widgets/icon_button.dart';
import '../../../../../shared/widgets/ripple_tap.dart';
import '../../../../../shared/widgets/scalable_tap.dart';
import '../../../../../topvars.dart';

part 'bangumi.g.dart';

class BangumiState {
  BangumiState({this.refreshFlag = 0, this.bangumiDetail, this.coverSize});
  final int refreshFlag;
  final BangumiDetail? bangumiDetail;
  final Size? coverSize;

  BangumiState copyWith({int? refreshFlag, BangumiDetail? bangumiDetail, Size? coverSize}) {
    return BangumiState(
      refreshFlag: refreshFlag ?? this.refreshFlag,
      bangumiDetail: bangumiDetail ?? this.bangumiDetail,
      coverSize: coverSize ?? this.coverSize,
    );
  }
}

@riverpod
class Bangumi extends _$Bangumi {
  @override
  BangumiState build(String id, String cover) {
    return BangumiState();
  }

  Future<IndicatorResult> loadSubgroupList(String dataId) async {
    final sb = state.bangumiDetail?.subgroupBangumis[dataId];
    if ((sb?.records.length ?? 0) < 10) {
      return IndicatorResult.noMore;
    }
    final records = await MikanApi.bangumiMore(id, sb?.dataId ?? '', take: (sb?.records.length ?? 0) + 20);
    if (!ref.mounted) {
      return IndicatorResult.fail;
    }
    if (sb?.records.length == records.length) {
      return IndicatorResult.noMore;
    } else {
      // Null safety check - ensure bangumiDetail exists before modifying
      final currentDetail = state.bangumiDetail;
      if (currentDetail == null) {
        return IndicatorResult.fail;
      }

      // Create a new copy of bangumiDetail with updated records
      final updatedSubgroupBangumis = Map<String, SubgroupBangumi>.from(currentDetail.subgroupBangumis);
      final oldSubgroup = updatedSubgroupBangumis[dataId];
      if (oldSubgroup == null) {
        return IndicatorResult.fail;
      }

      final updatedSubgroup = SubgroupBangumi()
        ..name = oldSubgroup.name
        ..dataId = oldSubgroup.dataId
        ..rss = oldSubgroup.rss
        ..subscribed = oldSubgroup.subscribed
        ..sublang = oldSubgroup.sublang
        ..subgroups = oldSubgroup.subgroups
        ..state = oldSubgroup.state
        ..records = records;
      updatedSubgroupBangumis[dataId] = updatedSubgroup;

      final updatedDetail = BangumiDetail()
        ..id = currentDetail.id
        ..name = currentDetail.name
        ..cover = currentDetail.cover
        ..subscribed = currentDetail.subscribed
        ..intro = currentDetail.intro
        ..more = currentDetail.more
        ..subgroupBangumis = updatedSubgroupBangumis;

      updateIfMounted(
        ref,
        (current) => current.copyWith(bangumiDetail: updatedDetail, refreshFlag: current.refreshFlag + 1),
      );
      return IndicatorResult.success;
    }
  }

  Future<IndicatorResult> load() async {
    final bangumiDetail = await MikanApi.bangumi(id);
    if (!ref.mounted) {
      return IndicatorResult.fail;
    }
    updateIfMounted(
      ref,
      (current) => current.copyWith(bangumiDetail: bangumiDetail, refreshFlag: current.refreshFlag + 1),
    );
    '加载完成'.toast();
    return IndicatorResult.success;
  }
}

@immutable
class BangumiPage extends ConsumerStatefulWidget {
  const BangumiPage({super.key, required this.bangumiId, required this.cover, this.name});

  final String bangumiId;
  final String cover;
  final String? name;

  @override
  ConsumerState<BangumiPage> createState() => _BangumiPageState();
}

class _BangumiPageState extends ConsumerState<BangumiPage> {
  final _scrollRatio = ValueNotifier<double>(0);

  @override
  void dispose() {
    _scrollRatio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerBackgroundColor = ColorTween(
      begin: theme.colorScheme.surface.withValues(alpha: 0.0),
      end: theme.colorScheme.surface,
    );

    // Watch provider once at build start - best practice
    final bangumiState = ref.watch(bangumiProvider(widget.bangumiId, widget.cover));
    final bangumiDetail = bangumiState.bangumiDetail;
    final subscribed = bangumiDetail?.subscribed ?? false;
    final bangumiName = bangumiDetail?.name;

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
              child: _buildBody(context, ref, theme, _scrollRatio, bangumiState),
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
                  padding: EdgeInsets.only(top: 12.0 + context.statusBarHeight, left: 12.0, right: 12.0, bottom: 8.0),
                  child: Row(
                    children: [
                      const BackIconButton(),
                      const Gap(16),
                      if (ratio > 0.88)
                        Expanded(
                          child: Text(
                            widget.name ?? bangumiName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge,
                          ),
                        )
                      else
                        spacer,
                      const Gap(16),
                      IconButton(
                        onPressed: () {
                          bangumiDetail?.share.share();
                        },
                        icon: const Icon(Icons.share_rounded),
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          // Watch the mutation state for this specific bangumi
                          final subscribeState = ref.watch(subscribeMutation(widget.bangumiId));

                          if (subscribeState is MutationPending) {
                            return const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: ExpressiveLoadingIndicator(
                                constraints: BoxConstraints.tightFor(width: 24.0, height: 24.0),
                              ),
                            );
                          }

                          return IconButton(
                            onPressed: () async {
                              await subscribeBangumi(ref, widget.bangumiId, subscribed);
                              // Reload bangumi detail to update subscribed state
                              await ref.read(bangumiProvider(widget.bangumiId, widget.cover).notifier).load();
                            },
                            icon: Icon(
                              subscribed ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: subscribed ? theme.secondary : null,
                            ),
                          );
                        },
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
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ValueNotifier<double> scrollRatio,
    BangumiState bangumiState,
  ) {
    final safeArea = MediaQuery.of(context).padding;
    final detail = bangumiState.bangumiDetail;
    final notNull = detail != null;
    final subgroups = detail?.subgroupBangumis.entries;
    final List<Widget> subTags = [];
    final List<Widget> subList = [];
    if (subgroups != null) {
      for (final e in subgroups) {
        final length = e.value.records.length;
        final maxItemLen = length > 4 ? 4 : length;
        subList.addAll([
          const Gap(24),
          Row(
            children: [
              Expanded(child: Text(e.value.name, style: theme.textTheme.titleLarge)),
              const Gap(8),
              if (!e.value.rss.isNullOrBlank)
                ElevatedButton(
                  onPressed: () {
                    e.value.rss.copy();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(32.0, 32.0),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
                  ),
                  child: e.value.subscribed
                      ? Row(children: [const Icon(Icons.rss_feed_rounded), const Gap(4), Text(e.value.sublang!)])
                      : const Icon(Icons.rss_feed_rounded),
                ),
              Transform.translate(
                offset: const Offset(12.0, 0.0),
                child: IconButton(
                  onPressed: () {
                    _showSubgroupPanel(context, e.value.dataId);
                  },
                  icon: const Icon(Icons.east_rounded),
                ),
              ),
            ],
          ),
          const Gap(12),
          for (int index = 0; index < maxItemLen; index++)
            ProviderScope(
              overrides: [currentRecordProvider.overrideWithValue(e.value.records[index])],
              child: const Padding(padding: EdgeInsets.only(bottom: 8.0), child: SimpleRecordItem()),
            ),
        ]);
        subTags.add(
          Tooltip(
            message: e.value.name,
            child: RippleTap(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: const RoundedSuperellipseBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
              onTap: () {
                _showSubgroupPanel(context, e.key);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  e.value.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge!.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                    image: CacheImage(widget.cover),
                    alignment: Alignment.topCenter,
                    isAntiAlias: true,
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.surface.withValues(alpha: 0.64), theme.colorScheme.surface],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.56],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 120.0 + context.statusBarHeight),
            child: Row(
              children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 16.0), child: _buildCover(widget.cover)),
                const Gap(16),
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
                              style: theme.textTheme.titleLarge?.copyWith(color: theme.secondary),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Gap(4),
                          ...detail.more.entries.mapIndexed((index, e) {
                            final child = Row(
                              children: [
                                Text('${e.key}：', softWrap: true, style: theme.textTheme.labelLarge),
                                if (e.value.startsWith('http'))
                                  RippleTap(
                                    onTap: () {
                                      e.value.launchAppAndCopy();
                                    },
                                    child: Text('打开链接', softWrap: true, style: theme.textTheme.labelLarge),
                                  )
                                else
                                  Text(e.value, softWrap: true, style: theme.textTheme.labelLarge),
                              ],
                            );
                            return index == detail.more.length - 1
                                ? child
                                : Padding(padding: const EdgeInsets.only(bottom: 8.0), child: child);
                          }),
                        ],
                      ),
                    ),
                  )
                else if (widget.name != null)
                  Expanded(
                    child: Tooltip(
                      message: widget.name,
                      child: AutoSizeText(
                        '${widget.name}\n',
                        style: theme.textTheme.titleLarge?.copyWith(color: theme.secondary),
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
        child: Container(color: theme.colorScheme.surface, height: 36.0),
      ),
      if (subTags.isNotEmpty) ...[
        Row(
          children: [
            Expanded(child: Text('字幕组', style: theme.textTheme.titleLarge)),
            ElevatedButton.icon(
              onPressed: () {
                MBottomSheet.show(
                  context,
                  (context) => MBottomSheet(
                    heightFactor: 0.78,
                    child: SubgroupSubscribe(bangumiId: widget.bangumiId, bangumiCover: widget.cover),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0.0, 32.0),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
              ),
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('订阅管理'),
            ),
          ],
        ),
        const Gap(8),
        Wrap(spacing: 8.0, runSpacing: 8.0, children: subTags),
      ],
      if (notNull && detail.intro.isNotBlank) ...[
        const Gap(24),
        Text('概况简介', style: theme.textTheme.titleLarge),
        const Gap(12),
        SelectionArea(
          child: Text(detail.intro, textAlign: TextAlign.justify, softWrap: true, style: theme.textTheme.bodyLarge),
        ),
      ],
      ...subList,
    ];
    return Container(
      constraints: const BoxConstraints(maxWidth: 640.0),
      child: EasyRefresh(
        onRefresh: () => ref.read(bangumiProvider(widget.bangumiId, widget.cover).notifier).load(),
        refreshOnStart: true,
        header: defaultHeader,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return items[index];
          },
          itemCount: items.length,
          padding: EdgeInsets.only(left: 24.0, right: 24.0, bottom: safeArea.bottom + 36.0),
        ),
      ),
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
                    padding: const EdgeInsets.all(2.0),
                    child: Center(child: Assets.mikan.image()),
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
                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.color),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSubgroupPanel(BuildContext context, String dataId) {
    MBottomSheet.show(
      context,
      (context) => MBottomSheet(
        heightFactor: 0.78,
        child: SubgroupBangumis(bangumiId: widget.bangumiId, bangumiCover: widget.cover, dataId: dataId),
      ),
    );
  }
}
