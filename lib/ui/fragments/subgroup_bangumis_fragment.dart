import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/bangumi_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/components/simple_record_item.dart';
import 'package:mikan_flutter/ui/fragments/subgroup_fragment.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:mikan_flutter/widget/sliver_pinned_header.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@immutable
class SubgroupBangumisFragment extends StatelessWidget {
  final BangumiModel bangumiModel;
  final String dataId;

  const SubgroupBangumisFragment({
    Key? key,
    required this.bangumiModel,
    required this.dataId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: ChangeNotifierProvider.value(
        value: bangumiModel,
        child: Builder(builder: (context) {
          final model = Provider.of<BangumiModel>(context, listen: false);
          final subgroupBangumi =
              model.bangumiDetail!.subgroupBangumis[dataId]!;
          return SmartRefresher(
            controller: bangumiModel.subgroupRefreshController,
            enablePullDown: false,
            enablePullUp: true,
            onLoading: () => bangumiModel.loadSubgroupList(dataId),
            footer: Indicator.footer(
              context,
              theme.secondary,
              bottom: 16.0,
            ),
            child: CustomScrollView(
              controller: ModalScrollController.of(context),
              slivers: [
                _buildHeader(
                  theme,
                  subgroupBangumi,
                ),
                _buildContentWrapper(
                  context,
                  theme,
                  subgroupBangumi,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContentWrapper(
    final BuildContext context,
    final ThemeData theme,
    final SubgroupBangumi subgroupBangumi,
  ) {
    return SliverPadding(
      padding: edgeH16V8,
      sliver: Selector<BangumiModel, List<RecordItem>>(
        selector: (_, model) => subgroupBangumi.records,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, records, __) {
          return SliverWaterfallFlow(
            delegate: SliverChildBuilderDelegate((context, ind) {
              final RecordItem record = records[ind];
              return SimpleRecordItem(
                index: ind,
                theme: theme,
                record: record,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.recordDetail.name,
                    arguments: Routes.recordDetail.d(url: record.url),
                  );
                },
              );
            }, childCount: records.length),
            gridDelegate: const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    final ThemeData theme,
    final SubgroupBangumi subgroupBangumi,
  ) {
    final it = ColorTween(
      begin: theme.backgroundColor,
      end: theme.scaffoldBackgroundColor,
    );
    return SimpleSliverPinnedHeader(
      maxExtent: 128.0,
      minExtent: 56.0,
      builder: (context, ratio) {
        final ic = it.transform(ratio);
        return Row(
          children: [
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: ic,
              minWidth: 32.0,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: circleShape,
              child: const Icon(
                FluentIcons.chevron_left_24_regular,
                size: 16.0,
              ),
            ),
            sizedBoxW12,
            Expanded(
              child: Text(
                subgroupBangumi.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 30.0 - (ratio * 6.0),
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
            ),
            if (subgroupBangumi.subgroups.isNotEmpty)
              Tooltip(
                message: '查看字幕组详情',
                child: MaterialButton(
                  onPressed: () {
                    final List<Subgroup> subgroups = subgroupBangumi.subgroups;
                    if (subgroups.length == 1) {
                      final Subgroup subgroup = subgroups[0];
                      Navigator.pushNamed(
                        context,
                        Routes.subgroup.name,
                        arguments: Routes.subgroup.d(subgroup: subgroup),
                      );
                    } else {
                      _showSubgroupPanel(
                        context,
                        subgroups,
                      );
                    }
                  },
                  color: ic,
                  minWidth: 32.0,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: circleShape,
                  child: const Icon(
                    FluentIcons.shifts_team_24_regular,
                    size: 16.0,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  _showSubgroupPanel(
    final BuildContext context,
    final List<Subgroup> subgroups,
  ) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      topRadius: radius16,
      builder: (context) {
        return SubgroupFragment(subgroups: subgroups);
      },
    );
  }
}
