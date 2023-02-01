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
import 'package:mikan_flutter/widget/icon_button.dart';
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
                      Routes.recordDetail.name,
                      arguments: Routes.recordDetail.d(url: record.url),
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

  Widget _buildHeader(
    final ThemeData theme,
    final SubgroupBangumi subgroupBangumi,
  ) {
    final it = ColorTween(
      begin: theme.colorScheme.background,
      end: theme.scaffoldBackgroundColor,
    );
    return StackSliverPinnedHeader(
      maxExtent: 136.0,
      minExtent: 60.0,
      childrenBuilder: (context, ratio) {
        final ic = it.transform(ratio);
        final titleRight = ratio * 56.0;
        return [
          Positioned(
            left: 0,
            top: 12.0,
            child: CircleBackButton(color: ic),
          ),
          if (subgroupBangumi.subgroups.isNotEmpty)
            Positioned(
              right: 0,
              top: 12.0,
              child: Tooltip(
                message: '查看字幕组详情',
                child: SmallCircleButton(
                  onTap: () {
                    final subgroups = subgroupBangumi.subgroups;
                    if (subgroups.length == 1) {
                      final subgroup = subgroups[0];
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
                  icon: Icons.groups_rounded,
                ),
              ),
            ),
          Positioned(
            top: 78.0 * (1 - ratio) + 18.0,
            left: titleRight,
            right: titleRight,
            child: Text(
              subgroupBangumi.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24.0 - (ratio * 4.0),
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ];
      },
    );
  }

  void _showSubgroupPanel(
    final BuildContext context,
    final List<Subgroup> subgroups,
  ) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      topRadius: radius0,
      builder: (context) {
        return SubgroupFragment(subgroups: subgroups);
      },
    );
  }
}
