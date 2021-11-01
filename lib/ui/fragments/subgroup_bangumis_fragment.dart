import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
          return NotificationListener(
            onNotification: (notification) {
              if (notification is OverscrollIndicatorNotification) {
                notification.disallowGlow();
              } else if (notification is ScrollUpdateNotification) {
                if (notification.depth == 0) {
                  final double offset = notification.metrics.pixels;
                  model.hasScrolled = offset > 0.0;
                }
              }
              return true;
            },
            child: Column(
              children: [
                _buildHeader(
                  context,
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
    return Expanded(
      child: Selector<BangumiModel, List<RecordItem>>(
        selector: (_, model) => subgroupBangumi.records,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, records, __) {
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
            child: WaterfallFlow.builder(
              padding: edgeH16V8,
              controller: ModalScrollController.of(context),
              itemCount: records.length,
              itemBuilder: (context, ind) {
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
              gridDelegate:
                  const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
                minCrossAxisExtent: 400.0,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    final BuildContext context,
    final ThemeData theme,
    final SubgroupBangumi subgroupBangumi,
  ) {
    return Selector<BangumiModel, bool>(
      selector: (_, model) => model.hasScrolled,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, hasScrolled, child) {
        return AnimatedContainer(
          padding: edgeVT16R8,
          decoration: BoxDecoration(
            color: hasScrolled
                ? theme.backgroundColor
                : theme.scaffoldBackgroundColor,
            borderRadius: scrollHeaderBorderRadius(hasScrolled),
            boxShadow: scrollHeaderBoxShadow(hasScrolled),
          ),
          duration: dur240,
          child: child,
        );
      },
      child: Row(
        children: [
          MaterialButton(
            minWidth: 32.0,
            color: theme.backgroundColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: circleShape,
            padding: EdgeInsets.zero,
            child: const Icon(
              FluentIcons.chevron_left_24_regular,
              size: 16.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          sizedBoxW12,
          Expanded(
            child: Text(
              subgroupBangumi.name,
              style: textStyle24B,
            ),
          ),
          if (subgroupBangumi.subgroups.isNotEmpty)
            IconButton(
              padding: EdgeInsets.zero,
              tooltip: "查看字幕组详情",
              icon: const Icon(FluentIcons.people_team_24_regular),
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
            ),
        ],
      ),
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
