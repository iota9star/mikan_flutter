import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/mutation.dart';

import '../../../features/bangumi/ui/bangumi.dart';
import '../../../shared/internal/app_utils.dart';
import '../../../shared/internal/extension.dart';
import '../../../shared/services/subscription_service.dart' show subscribeBangumi, subscribeMutation;
import '../../../topvars.dart';
import '../../widgets/sliver_pinned_header.dart';

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
              child: Text(
                '注：\n仅会显示订阅/RSS时适用，番组详情列表仍为全部条目。\n如果选择语言时最终未选中选择的值，说明当前字幕组不支持订阅选择的语言。',
                style: theme.textTheme.bodyMedium,
              ),
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
                    SegmentedButton<int>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: 0, label: Text('全部')),
                        ButtonSegment(value: 1, label: Text('简中')),
                        ButtonSegment(value: 2, label: Text('繁中')),
                        ButtonSegment(value: -1, label: Text('退订')),
                      ],
                      selected: {sub.state},
                      style: ButtonStyle(
                        shape: WidgetStateProperty.resolveWith((states) {
                          return const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0)));
                        }),
                      ),
                      onSelectionChanged: (v) {
                        wrapLoading(() async {
                          final x = v.first;
                          await subscribeBangumi(ref, bangumiId, x == -1, subgroupId: sub.dataId);
                          await ref.read(bangumiProvider(bangumiId, bangumiCover).notifier).load();
                        });
                      },
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
