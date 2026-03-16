import 'package:easy_refresh/easy_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFAutoImport()
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/core/common/delegate.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/kit.dart';
@FFAutoImport()
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/components/rss_record_item.dart';
import 'package:mikan/core/components/simple_record_item.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';
import 'package:mikan/features/home/application/index_provider.dart';
import 'package:mikan/features/subscription/application/recent_subscribed_provider.dart';

@FFRoute(name: '/subscribed/recent')
@immutable
class RecentSubscribedPage extends ConsumerWidget {
  const RecentSubscribedPage({super.key, required this.loaded});

  final List<RecordItem> loaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final rss = ref.watch(indexProvider).value?.user?.rss;

    // Watch the AsyncValue state
    final stateAsync = ref.watch(recentSubscribedProvider(loaded));

    return Scaffold(
      body: stateAsync.when(
        data: (state) {
          return EasyRefresh(
            refreshOnStart: loaded.isEmpty,
            header: defaultHeader,
            footer: defaultFooter(context),
            onRefresh: () => ref.read(recentSubscribedProvider(loaded).notifier).refresh(),
            onLoad: () => ref.read(recentSubscribedProvider(loaded).notifier).loadMore(),
            child: CustomScrollView(
              slivers: [
                SliverPinnedAppBar(
                  title: '最近更新',
                  actions: [
                    if (rss.isNullOrBlank)
                      const SizedBox.shrink()
                    else
                      IconButton(onPressed: rss.copy, icon: const Icon(Icons.rss_feed_rounded)),
                  ],
                ),
                _buildList(theme, state.records),
              ],
            ),
          );
        },
        loading: () => const Scaffold(body: Center(child: ExpressiveLoadingIndicator())),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('加载失败: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(recentSubscribedProvider(loaded).notifier).refresh(),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(ThemeData theme, List<RecordItem> records) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      sliver: Builder(
        builder: (context) {
          final margins = context.margins;
          return SliverWaterfallFlow(
            gridDelegate: SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 300.0,
              crossAxisSpacing: margins,
              mainAxisSpacing: margins,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final record = records[index];
              return ProviderScope(
                overrides: [currentRecordProvider.overrideWithValue(record)],
                child: const RssRecordItem(),
              );
            }, childCount: records.length),
          );
        },
      ),
    );
  }
}
