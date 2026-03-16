import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/mutation.dart';

import 'package:mikan/features/bangumi/presentation/pages/bangumi.dart';
import 'package:mikan/core/common/app_utils.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';
import 'package:mikan/features/subscription/application/subscription_service.dart'
    show subscribeBangumi, subscribeMutation;

class SubgroupSubscribe extends ConsumerWidget {
  const SubgroupSubscribe({required this.bangumiId, required this.bangumiCover, super.key});

  final String bangumiId;
  final String bangumiCover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Only rebuild when bangumiDetail changes
    final bangumiDetail = ref.watch(bangumiProvider(bangumiId, bangumiCover).select((state) => state.bangumiDetail));
    final subscribed = bangumiDetail?.subscribed ?? false;
    final subgroups = bangumiDetail?.subgroupBangumis.values.toList(growable: false) ?? [];
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPinnedAppBar(
            title: '字幕组订阅',
            actions: [_SubscribeButton(bangumiId: bangumiId, bangumiCover: bangumiCover, subscribed: subscribed)],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text('注：\n当前版本仅支持按字幕组订阅/退订。\n订阅语言状态会按站点当前返回结果展示，番组详情列表仍为全部条目。', style: theme.textTheme.bodyMedium),
            ),
          ),
          SliverList.builder(
            itemBuilder: (context, index) {
              final sub = subgroups[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(sub.name, style: theme.textTheme.titleMedium)),
                        if (sub.rss.isNotBlank)
                          ElevatedButton(
                            onPressed: () {
                              sub.rss.copy();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(32.0, 32.0),
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
                            ),
                            child: sub.subscribed
                                ? Row(children: [const Icon(Icons.rss_feed_rounded), const Gap(4), Text(sub.sublang!)])
                                : const Icon(Icons.rss_feed_rounded),
                          ),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sub.subscribed ? '已订阅 ${sub.sublang ?? "全部"}' : '未订阅',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            wrapLoading(() async {
                              await subscribeBangumi(ref, bangumiId, sub.subscribed, subgroupId: sub.dataId);
                              await ref.read(bangumiProvider(bangumiId, bangumiCover).notifier).load();
                            });
                          },
                          icon: Icon(
                            sub.subscribed ? Icons.notifications_off_rounded : Icons.notifications_active_rounded,
                          ),
                          label: Text(sub.subscribed ? '退订' : '订阅'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            itemCount: subgroups.length,
          ),
          sliverGapH24WithNavBarHeight(context),
        ],
      ),
    );
  }
}

class _SubscribeButton extends ConsumerWidget {
  const _SubscribeButton({required this.bangumiId, required this.bangumiCover, required this.subscribed});

  final String bangumiId;
  final String bangumiCover;
  final bool subscribed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscribeState = ref.watch(subscribeMutation(bangumiId));
    final isLoading = subscribeState is MutationPending;

    return IconButton(
      onPressed: isLoading
          ? null
          : () async {
              await subscribeBangumi(ref, bangumiId, subscribed);
              // Reload bangumi detail to update subscribed state
              await ref.read(bangumiProvider(bangumiId, bangumiCover).notifier).load();
            },
      icon: Icon(
        subscribed ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: subscribed ? theme.colorScheme.secondary : null,
      ),
    );
  }
}
