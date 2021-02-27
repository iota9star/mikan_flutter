import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/view_models/bangumi_model.dart';
import 'package:mikan_flutter/providers/view_models/op_model.dart';
import 'package:mikan_flutter/ui/components/simple_record_item.dart';
import 'package:mikan_flutter/ui/fragments/subgroup_fragment.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@immutable
class BangumiSubgroupFragment extends StatelessWidget {
  final BangumiModel bangumiModel;

  const BangumiSubgroupFragment({
    Key key,
    @required this.bangumiModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: ChangeNotifierProvider.value(
        value: bangumiModel,
        child: Builder(builder: (context) {
          final BangumiModel bangumiModel =
              Provider.of<BangumiModel>(context, listen: false);
          return NotificationListener(
            onNotification: (notification) {
              if (notification is OverscrollIndicatorNotification) {
                notification.disallowGlow();
              } else if (notification is ScrollUpdateNotification) {
                if (notification.depth == 0) {
                  final double offset = notification.metrics.pixels;
                  bangumiModel.hasScrolled = offset > 0.0;
                }
              }
              return true;
            },
            child: Selector<BangumiModel, SubgroupBangumi>(
              selector: (_, model) => model.subgroupBangumi,
              shouldRebuild: (pre, next) => pre != next,
              builder: (context, subgroupBangumi, child) {
                if (subgroupBangumi == null) return Container();
                return Column(
                  children: [
                    _buildHeader(
                      context,
                      theme,
                      subgroupBangumi,
                    ),
                    _buildContentWrapper(
                      context,
                      theme,
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContentWrapper(
    final BuildContext context,
    final ThemeData theme,
  ) {
    return Expanded(
      child: Selector<BangumiModel, List<RecordItem>>(
        selector: (_, model) => model.subgroupBangumi.records,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, records, __) {
          return SmartRefresher(
            controller: bangumiModel.refreshController,
            enablePullDown: false,
            enablePullUp: true,
            onLoading: bangumiModel.loadSubgroupList,
            footer: Indicator.footer(
              context,
              theme.accentColor,
              bottom: 16.0 + Sz.navBarHeight,
            ),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              controller: ModalScrollController.of(context),
              itemCount: records.length,
              itemBuilder: (context, ind) {
                final RecordItem record = records[ind];
                final String currFlag = "bs:$ind:${record.url}";
                return Selector<OpModel, String>(
                  selector: (_, model) => model.rebuildFlag,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (_, tapFlag, __) {
                    final Matrix4 transform = tapFlag == currFlag
                        ? Matrix4.diagonal3Values(0.9, 0.9, 1)
                        : Matrix4.identity();
                    return SimpleRecordItem(
                      index: ind,
                      theme: theme,
                      record: record,
                      transform: transform,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.recordDetail.name,
                          arguments: Routes.recordDetail.d(url: record.url),
                        );
                      },
                      onTapStart: () {
                        context.read<OpModel>().rebuildFlag = currFlag;
                      },
                      onTapEnd: () {
                        context.read<OpModel>().rebuildFlag = null;
                      },
                    );
                  },
                );
              },
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
          padding: EdgeInsets.only(
            right: 8.0,
            left: 16.0,
            top: 16.0,
            bottom: 16.0,
          ),
          decoration: BoxDecoration(
            color: hasScrolled
                ? theme.backgroundColor
                : theme.scaffoldBackgroundColor,
            borderRadius: hasScrolled
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  )
                : null,
            boxShadow: hasScrolled
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.024),
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      spreadRadius: 3.0,
                    ),
                  ]
                : null,
          ),
          duration: Duration(milliseconds: 240),
          child: child,
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              subgroupBangumi.name,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),
          ),
          if (subgroupBangumi.subgroups.isNotEmpty)
            IconButton(
              padding: EdgeInsets.zero,
              tooltip: "查看字幕组详情",
              icon: Icon(FluentIcons.group_24_regular),
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
          IconButton(
            padding: EdgeInsets.zero,
            tooltip: "返回上一页",
            icon: Icon(FluentIcons.dismiss_24_regular),
            onPressed: () {
              Navigator.pop(context);
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
      topRadius: Radius.circular(16.0),
      builder: (context) {
        return SubgroupFragment(subgroups: subgroups);
      },
    );
  }
}
