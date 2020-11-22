import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/models/bangumi_model.dart';
import 'package:mikan_flutter/ui/components/simple_record_item.dart';
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
    final Color accentColor = Theme.of(context).accentColor;
    final Color primaryColor = Theme.of(context).primaryColor;
    final TextStyle fileTagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    final Color primaryTextColor =
        primaryColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
    final TextStyle titleTagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: primaryTextColor,
    );
    final Color scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;
    final Color backgroundColor = Theme.of(context).backgroundColor;
    return Material(
      color: scaffoldBackgroundColor,
      child: ChangeNotifierProvider.value(
        value: bangumiModel,
        child: Builder(builder: (context) {
          return NotificationListener(
            onNotification: (notification) {
              if (notification is OverscrollIndicatorNotification) {
                notification.disallowGlow();
              } else if (notification is ScrollUpdateNotification) {
                if (notification.depth == 0) {
                  final double offset = notification.metrics.pixels;
                  context
                      .read<BangumiModel>()
                      .setScrolledSubgroupRecords(offset > 0.0);
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
                      primaryColor,
                      primaryTextColor,
                      backgroundColor,
                      scaffoldBackgroundColor,
                      subgroupBangumi,
                    ),
                    _buildContentWrapper(
                      context,
                      primaryColor,
                      accentColor,
                      backgroundColor,
                      titleTagStyle,
                      fileTagStyle,
                      subgroupBangumi,
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
    final Color primaryColor,
    final Color accentColor,
    final Color backgroundColor,
    final TextStyle titleTagStyle,
    final TextStyle fileTagStyle,
    final SubgroupBangumi subgroupBangumi,
  ) {
    return Expanded(
      child: SmartRefresher(
        controller: bangumiModel.refreshController,
        enablePullDown: false,
        enablePullUp: true,
        onLoading: bangumiModel.loadSubgroupList,
        footer: Indicator.footer(
          context,
          accentColor,
          bottom: 16.0 + Sz.navBarHeight,
        ),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          controller: ModalScrollController.of(context),
          itemCount: subgroupBangumi.records.length,
          itemBuilder: (context, ind) {
            final record = subgroupBangumi.records[ind];
            return Selector<BangumiModel, int>(
              selector: (_, model) => model.tapRecordItemFlag,
              shouldRebuild: (pre, next) => pre != next,
              builder: (_, tapFlag, __) {
                final Matrix4 transform = tapFlag == ind
                    ? Matrix4.diagonal3Values(0.9, 0.9, 1)
                    : Matrix4.identity();
                return SimpleRecordItem(
                  index: ind,
                  accentColor: accentColor,
                  fileTagStyle: fileTagStyle,
                  primaryColor: primaryColor,
                  backgroundColor: backgroundColor,
                  titleTagStyle: titleTagStyle,
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
                    bangumiModel.tapRecordItemFlag = ind;
                  },
                  onTapEnd: () {
                    bangumiModel.tapRecordItemFlag = -1;
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    final BuildContext context,
    final Color primaryColor,
    final Color primaryTextColor,
    final Color backgroundColor,
    final Color scaffoldBackgroundColor,
    final SubgroupBangumi subgroupBangumi,
  ) {
    return Selector<BangumiModel, bool>(
      selector: (_, model) => model.hasScrolledSubgroupRecords,
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
            color: hasScrolled ? backgroundColor : scaffoldBackgroundColor,
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
                  _push2SubgroupPage(context, subgroup);
                } else {
                  _showSubgroupPanel(
                    context,
                    primaryColor,
                    primaryTextColor,
                    backgroundColor,
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

  void _push2SubgroupPage(BuildContext context, Subgroup subgroup) {
    Navigator.pushNamed(
      context,
      Routes.subgroup.name,
      arguments: Routes.subgroup.d(subgroup: subgroup),
    );
  }

  _showSubgroupPanel(
    final BuildContext context,
    final Color primaryColor,
    final Color primaryTextColor,
    final Color backgroundColor,
    final List<Subgroup> subgroups,
  ) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      topRadius: Radius.circular(16.0),
      builder: (context) {
        return Material(
          color: backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  bottom: 8.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: const Text("请选择字幕组"),
              ),
              ...List.generate(
                subgroups.length,
                (index) {
                  final Subgroup subgroup = subgroups[index];
                  return InkWell(
                    onTap: () {
                      _push2SubgroupPage(context, subgroup);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24.0,
                            height: 24.0,
                            child: Center(
                              child: Text(
                                subgroups[index].name[0],
                                style: TextStyle(
                                  fontSize: 12.0,
                                  height: 1.25,
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.56),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Expanded(
                            child: Text(
                              subgroup.name,
                              style: TextStyle(
                                height: 1.25,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 8.0 + Sz.navBarHeight,
              )
            ],
          ),
        );
      },
    );
  }
}
