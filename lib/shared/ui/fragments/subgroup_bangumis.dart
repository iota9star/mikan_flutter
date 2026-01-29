import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../../features/bangumi/ui/bangumi.dart';
import '../../../mikan_routes.dart';
import '../../../shared/internal/delegate.dart';
import '../../../shared/internal/extension.dart';
import '../../../topvars.dart';
import '../../models/subgroup.dart';
import '../../models/subgroup_bangumi.dart';
import '../../widgets/bottom_sheet.dart';
import '../../widgets/sliver_pinned_header.dart';
import '../components/simple_record_item.dart';
import 'select_subgroup.dart';

@immutable
class SubgroupBangumis extends ConsumerWidget {
  const SubgroupBangumis({super.key, required this.bangumiId, required this.bangumiCover, required this.dataId});

  final String bangumiId;
  final String bangumiCover;
  final String dataId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bangumiDetail = ref.watch(bangumiProvider(bangumiId, bangumiCover).select((state) => state.bangumiDetail));

    // Handle null cases safely
    if (bangumiDetail == null) {
      return const Scaffold(body: Center(child: Text('加载中...')));
    }

    final subgroupBangumi = bangumiDetail.subgroupBangumis[dataId];
    if (subgroupBangumi == null) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverPinnedAppBar(title: '字幕组'),
            SliverFillRemaining(
              child: Center(child: Text('未找到字幕组数据', style: theme.textTheme.bodyMedium)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: EasyRefresh(
        footer: defaultFooter(context),
        onLoad: () => ref.read(bangumiProvider(bangumiId, bangumiCover).notifier).loadSubgroupList(dataId),
        child: CustomScrollView(
          slivers: [
            SliverPinnedAppBar(
              title: subgroupBangumi.name,
              actions: [
                if (!subgroupBangumi.rss.isNullOrBlank)
                  IconButton(
                    onPressed: () {
                      subgroupBangumi.rss.copy();
                    },
                    icon: const Icon(Icons.rss_feed_rounded),
                  ),
                if (subgroupBangumi.subgroups.isNotEmpty)
                  IconButton(
                    tooltip: '查看字幕组',
                    onPressed: () {
                      final subgroups = subgroupBangumi.subgroups;
                      showSelectSubgroupPanel(context, subgroups);
                    },
                    icon: const Icon(Icons.group_rounded),
                  ),
              ],
            ),
            _buildList(theme, subgroupBangumi),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ThemeData theme, SubgroupBangumi subgroupBangumi) {
    return Builder(
      builder: (context) {
        final records = subgroupBangumi.records;
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          sliver: SliverWaterfallFlow(
            delegate: SliverChildBuilderDelegate((context, ind) {
              final record = records[ind];
              return ProviderScope(
                overrides: [currentRecordProvider.overrideWithValue(record)],
                child: const SimpleRecordItem(),
              );
            }, childCount: records.length),
            gridDelegate: const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
          ),
        );
      },
    );
  }
}

void showSelectSubgroupPanel(BuildContext context, List<Subgroup> subgroups) {
  if (subgroups.length == 1) {
    final subgroup = subgroups[0];
    if (subgroup.id == null) {
      '无字幕组详情'.toast();
      return;
    }
    Navigator.pushNamed(context, Routes.subgroup.name, arguments: Routes.subgroup.d(subgroup: subgroup));
  } else {
    MBottomSheet.show(context, (context) => MBottomSheet(child: SelectSubgroup(subgroups: subgroups)));
  }
}
