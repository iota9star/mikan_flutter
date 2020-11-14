import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/models/bangumi_details_model.dart';
import 'package:mikan_flutter/ui/components/simple_record_item.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@immutable
class BangumiDetailsSubgroupFragment extends StatelessWidget {
  final BangumiDetailsModel bangumiDetailsModel;

  const BangumiDetailsSubgroupFragment({
    Key key,
    @required this.bangumiDetailsModel,
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
    final TextStyle titleTagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color:
          primaryColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    final Color scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;
    final Color backgroundColor = Theme.of(context).backgroundColor;
    return Material(
      color: scaffoldBackgroundColor,
      child: ChangeNotifierProvider.value(
        value: bangumiDetailsModel,
        child: Builder(
          builder: (context) {
            return NotificationListener(
              onNotification: (notification) {
                if (notification is OverscrollIndicatorNotification) {
                  notification.disallowGlow();
                } else if (notification is ScrollUpdateNotification) {
                  if (notification.depth == 0) {
                    final double offset = notification.metrics.pixels;
                    context
                        .read<BangumiDetailsModel>()
                        .setScrolledSubgroupRecords(offset > 0.0);
                  }
                }
                return true;
              },
              child: Selector<BangumiDetailsModel, SubgroupBangumi>(
                selector: (_, model) => model.subgroupBangumi,
                shouldRebuild: (pre, next) => pre != next,
                builder: (context, subgroupBangumi, child) {
                  if (subgroupBangumi == null) return Container();
                  return Column(
                    children: [
                      Selector<BangumiDetailsModel, bool>(
                        selector: (_, model) =>
                            model.hasScrolledSubgroupRecords,
                        shouldRebuild: (pre, next) => pre != next,
                        builder: (_, hasScrolled, child) {
                          return AnimatedContainer(
                            padding: EdgeInsets.only(
                              right: 16.0,
                              top: 16.0,
                              bottom: 16.0,
                            ),
                            decoration: BoxDecoration(
                              color: hasScrolled
                                  ? backgroundColor
                                  : scaffoldBackgroundColor,
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
                            IconButton(
                              padding: EdgeInsets.zero,
                              tooltip: "返回上一页",
                              icon: Icon(FluentIcons.chevron_left_24_regular),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Expanded(
                              child: Text(
                                subgroupBangumi.name,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              tooltip: "查看字幕组详情",
                              icon: Icon(FluentIcons.library_24_regular),
                              onPressed: () {
                                final List<Subgroup> subgroups =
                                    subgroupBangumi.subgroups;
                                if (subgroups.length == 1) {
                                  final Subgroup subgroup = subgroups[0];
                                  _push2SubgroupPage(context, subgroup);
                                } else {
                                  _showSubgroupPanel(
                                    context,
                                    backgroundColor,
                                    subgroups,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SmartRefresher(
                          controller: bangumiDetailsModel.refreshController,
                          enablePullDown: false,
                          enablePullUp: true,
                          onLoading: bangumiDetailsModel.loadSubgroupList,
                          footer: Indicator.footer(
                            context,
                            accentColor,
                            bottom: 16.0,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            controller: ModalScrollController.of(context),
                            itemCount: subgroupBangumi.records.length,
                            itemBuilder: (context, ind) {
                              final record = subgroupBangumi.records[ind];
                              return Selector<BangumiDetailsModel, int>(
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
                                    onTap: () {},
                                    onTapStart: () {
                                      bangumiDetailsModel.tapRecordItemFlag =
                                          ind;
                                    },
                                    onTapEnd: () {
                                      bangumiDetailsModel.tapRecordItemFlag =
                                          -1;
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _push2SubgroupPage(BuildContext context, Subgroup subgroup) {
    Navigator.pushNamed(
      context,
      Routes.subgroup,
      arguments: {"subgroup": subgroup},
    );
  }

  _showSubgroupPanel(final BuildContext context,
      final Color backgroundColor,
      final List<Subgroup> subgroups,) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      topRadius: Radius.circular(16.0),
      builder: (context) {
        return Material(
          color: backgroundColor,
          child: ListView.builder(
            shrinkWrap: true,
            controller: ModalScrollController.of(context),
            padding: EdgeInsets.only(bottom: 8.0 + Sz.navBarHeight, top: 8.0),
            itemBuilder: (context, index) {
              final Subgroup subgroup = subgroups[index];
              return InkWell(
                onTap: () {
                  _push2SubgroupPage(context, subgroup);
                },
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        FluentIcons.contact_card_group_24_regular,
                        size: 28.0,
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      Expanded(
                        child: Text(
                          subgroup.name,
                          style: TextStyle(
                            height: 1.25,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: subgroups.length,
          ),
        );
      },
    );
  }
}
