import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../internal/delegate.dart';
import '../../internal/extension.dart';
import '../../mikan_routes.dart';
import '../../model/record_item.dart';
import '../../model/subgroup.dart';
import '../../model/subgroup_bangumi.dart';
import '../../providers/bangumi_model.dart';
import '../../topvars.dart';
import '../../widget/bottom_sheet.dart';
import '../../widget/sliver_pinned_header.dart';
import '../components/simple_record_item.dart';
import 'select_subgroup.dart';

@immutable
class SubgroupBangumis extends StatelessWidget {
  const SubgroupBangumis({
    super.key,
    required this.bangumiModel,
    required this.dataId,
  });

  final BangumiModel bangumiModel;
  final String dataId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ChangeNotifierProvider.value(
        value: bangumiModel,
        child: Builder(
          builder: (context) {
            final model = Provider.of<BangumiModel>(context, listen: false);
            final subgroupBangumi =
                model.bangumiDetail!.subgroupBangumis[dataId]!;
            return EasyRefresh(
              footer: defaultFooter(context),
              onLoad: () => bangumiModel.loadSubgroupList(dataId),
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
                  _buildList(
                    context,
                    theme,
                    subgroupBangumi,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ThemeData theme,
    SubgroupBangumi subgroupBangumi,
  ) {
    return SliverPadding(
      padding: edgeH24V8,
      sliver: Selector<BangumiModel, List<RecordItem>>(
        selector: (_, model) => subgroupBangumi.records,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, records, __) {
          return SliverWaterfallFlow(
            delegate: SliverChildBuilderDelegate(
              (context, ind) {
                final RecordItem record = records[ind];
                return SimpleRecordItem(
                  index: ind,
                  theme: theme,
                  record: record,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.record.name,
                      arguments: Routes.record.d(url: record.url),
                    );
                  },
                );
              },
              childCount: records.length,
            ),
            gridDelegate:
                const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
          );
        },
      ),
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
    Navigator.pushNamed(
      context,
      Routes.subgroup.name,
      arguments: Routes.subgroup.d(subgroup: subgroup),
    );
  } else {
    MBottomSheet.show(
      context,
      (context) => MBottomSheet(child: SelectSubgroup(subgroups: subgroups)),
    );
  }
}
