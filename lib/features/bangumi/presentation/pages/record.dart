import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFAutoImport()
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/mutation.dart';

import 'package:mikan/res/assets.gen.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/image_provider.dart';
import 'package:mikan/core/common/kit.dart';
import 'package:mikan/core/models/record_details.dart';
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/widgets/icon_button.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/features/bangumi/application/record_detail_provider.dart';
import 'package:mikan/features/subscription/application/subscription_service.dart'
    show subscribeBangumi, subscribeMutation;

@immutable
class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key, required this.record});

  final RecordItem record;

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage> {
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

    // Watch the AsyncValue and handle states
    final recordDetailAsync = ref.watch(recordDetailProvider(widget.record));

    return recordDetailAsync.maybeWhen(
      ready: (recordDetail) {
        return Scaffold(
          body: NotificationListener<ScrollUpdateNotification>(
            onNotification: (ScrollUpdateNotification notification) {
              final double offset = notification.metrics.pixels;
              if (offset >= 0) {
                _scrollRatio.value = math.min(1.0, offset / 96);
              }
              return true;
            },
            child: Stack(
              children: [
                _buildBody(context, theme, recordDetail),
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
                            const Gap(16),
                            if (ratio > 0.88)
                              Expanded(
                                child: Text(
                                  recordDetail.name,
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
                                recordDetail.share.share();
                              },
                              icon: const Icon(Icons.share_rounded),
                            ),
                            _buildSubscribeBtn(context, theme, recordDetail),
                            IconButton(
                              onPressed: () {
                                recordDetail.magnet.launchAppAndCopy();
                              },
                              icon: const Icon(Icons.downloading_rounded),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      failed: (failure) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载失败: ${failure.cause}'),
              const Gap(16),
              ElevatedButton(
                onPressed: () => refreshRecordDetail(ref, widget.record),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
      orElse: () => const Scaffold(body: Center(child: defaultLoadingWidget)),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, RecordDetail recordDetail) {
    final safeArea = MediaQuery.of(context).padding;
    final scale = (64.0 + context.screenWidth) / context.screenWidth;
    return Positioned.fill(
      child: Builder(
        builder: (context) {
          final list = [
            Stack(
              children: [
                if (!recordDetail.cover.endsWith('noimageavailble_icon.png'))
                  Positioned.fill(
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: CacheImage(recordDetail.cover),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBangumiCover(context, recordDetail),
                      const Gap(16),
                      Expanded(
                        child: SelectionArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Gap(12),
                              AutoSizeText(
                                recordDetail.name,
                                maxLines: 3,
                                style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.secondary),
                              ),
                              const Gap(8),
                              ...recordDetail.more.entries.map(
                                (e) => Text('${e.key}: ${e.value}', softWrap: true, style: theme.textTheme.bodyMedium),
                              ),
                            ],
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
            if (recordDetail.title.isNotBlank)
              SelectionArea(child: Text(recordDetail.title, style: theme.textTheme.bodyMedium)),
            const Gap(8),
            if (!recordDetail.tags.isNullOrEmpty)
              SelectionArea(
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: [
                    if (widget.record.size.isNotBlank)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                        decoration: ShapeDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          shape: const RoundedSuperellipseBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
                        ),
                        child: Text(
                          widget.record.size,
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                        ),
                      ),
                    ...List.generate(recordDetail.tags.length, (index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                        ),
                        child: Text(
                          recordDetail.tags[index],
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onTertiaryContainer),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            const Gap(24),
            if (recordDetail.intro.isNotEmpty) Text('概况简介', style: theme.textTheme.titleLarge),
            const Gap(12),
            SelectionArea(
              child: HtmlWidget(
                recordDetail.intro,
                onTapUrl: (url) {
                  url.launchAppAndCopy();
                  return true;
                },
                customWidgetBuilder: (element) {
                  if (element.localName == 'img') {
                    final String? src = element.attributes['src'];
                    if (src.isNotBlank) {
                      return _buildImageWidget(src!);
                    }
                  }
                  return null;
                },
              ),
            ),
          ];
          return EasyRefresh(
            onRefresh: () => refreshRecordDetail(ref, widget.record),
            header: defaultHeader,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return list[index];
              },
              itemCount: list.length,
              padding: EdgeInsets.only(left: 24.0, right: 24.0, bottom: safeArea.bottom + 36.0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBangumiCover(BuildContext context, RecordDetail record) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      child: Image(
        image: CacheImage(record.cover),
        width: 136.0,
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
        frameBuilder: (_, child, ___, ____) {
          return child;
        },
      ),
    );
  }

  Widget _buildSubscribeBtn(BuildContext context, ThemeData theme, RecordDetail recordDetail) {
    return SubscribeButton(
      bangumiId: recordDetail.id!,
      subscribed: recordDetail.subscribed,
      onSubscriptionChanged: () {
        invalidateRecordDetail(ref, widget.record);
      },
    );
  }

  Widget _buildImageWidget(String url) {
    final placeholder = AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        color: Colors.grey.withValues(alpha: 0.24),
        child: Center(child: Image.asset(Assets.mikan.path, width: 56.0)),
      ),
    );
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      child: Image(
        image: CacheImage(url),
        loadingBuilder: (_, child, event) {
          return event == null ? child : placeholder;
        },
        errorBuilder: (_, __, ___) {
          return placeholder;
        },
      ),
    );
  }
}

class SubscribeButton extends ConsumerWidget {
  const SubscribeButton({
    super.key,
    required this.bangumiId,
    required this.subscribed,
    required this.onSubscriptionChanged,
  });

  final String bangumiId;
  final bool subscribed;
  final VoidCallback onSubscriptionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscribeState = ref.watch(subscribeMutation(bangumiId));

    if (subscribeState is MutationPending) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: ExpressiveLoadingIndicator(constraints: BoxConstraints.tightFor(width: 24.0, height: 24.0)),
      );
    }

    return subscribed
        ? IconButton(
            tooltip: '取消订阅',
            icon: Icon(Icons.favorite_rounded, color: theme.colorScheme.error),
            onPressed: () async {
              await subscribeBangumi(ref, bangumiId, subscribed);
              onSubscriptionChanged();
            },
          )
        : IconButton(
            tooltip: '订阅',
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () async {
              await subscribeBangumi(ref, bangumiId, subscribed);
              onSubscriptionChanged();
            },
          );
  }
}
