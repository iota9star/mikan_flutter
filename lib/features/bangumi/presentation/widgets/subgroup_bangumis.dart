import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'package:mikan/features/bangumi/presentation/pages/bangumi.dart';
import 'package:mikan/app/routing/mikan_routes.dart';
import 'package:mikan/core/common/delegate.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/core/models/subgroup.dart';
import 'package:mikan/core/models/subgroup_bangumi.dart';
import 'package:mikan/core/widgets/bottom_sheet.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';
import 'package:mikan/core/components/record_sliver_delegate.dart';
import 'package:mikan/core/components/simple_record_item.dart';
import 'package:mikan/features/bangumi/presentation/widgets/select_subgroup.dart';

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
            delegate: recordItemDelegate(records, const SimpleRecordItem()),
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
