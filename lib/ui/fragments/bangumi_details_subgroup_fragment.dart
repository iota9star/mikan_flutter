import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/models/bangumi_details_model.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@immutable
class BangumiDetailsSubgroupFragment extends StatelessWidget {
  final ScrollController scrollController;
  final BangumiDetailsModel bangumiDetailsModel;

  const BangumiDetailsSubgroupFragment({
    Key key,
    @required this.scrollController,
    @required this.bangumiDetailsModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).accentColor;
    final TextStyle tagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
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
                    print('offset: $offset');
                    context
                        .read<BangumiDetailsModel>()
                        .setScrolledSubgroupRecords(offset > 0);
                  }
                }
                return false;
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
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                color: scaffoldBackgroundColor,
                                boxShadow: hasScrolled
                                    ? [
                                  BoxShadow(
                                    color:
                                    Colors.black.withOpacity(0.024),
                                    offset: Offset(0, 1),
                                    blurRadius: 3.0,
                                    spreadRadius: 3.0,
                                  ),
                                ]
                                    : null),
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
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              tooltip: "关闭",
                              icon: Icon(FluentIcons.dismiss_24_regular),
                              onPressed: () {
                                Navigator.pop(context);
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
                          footer: Indicator.footer(context, accentColor,
                              bottom: 16.0),
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: subgroupBangumi.records.length,
                            itemBuilder: (context, ind) {
                              final record = subgroupBangumi.records[ind];
                              return _buildRecordItem(
                                ind,
                                record,
                                accentColor,
                                backgroundColor,
                                tagStyle,
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

  Widget _buildRecordItem(final int index,
      final RecordItem record,
      final Color accentColor,
      final Color backgroundColor,
      final TextStyle tagStyle,) {
    return AnimatedTapContainer(
      margin: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Text(
              record.title,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Wrap(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    right: 4.0,
                    bottom: 4.0,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.87),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: Text(
                    record.publishAt,
                    style: tagStyle,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    right: 4.0,
                    bottom: 4.0,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.87),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: Text(
                    record.size,
                    style: tagStyle,
                  ),
                ),
                if (!record.tags.isNullOrEmpty)
                  ...List.generate(record.tags.length, (index) {
                    return Container(
                      margin: EdgeInsets.only(
                        right: 4.0,
                        bottom: 4.0,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.87),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      child: Text(
                        record.tags[index],
                        style: tagStyle,
                      ),
                    );
                  }),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(FluentIcons.channel_24_regular),
                color: accentColor,
                tooltip: "打开详情页",
                iconSize: 20.0,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(FluentIcons.cloud_download_24_regular),
                tooltip: "复制并尝试打开种子链接",
                color: accentColor,
                iconSize: 20.0,
                onPressed: () {
                  record.torrent.launchApp();
                  record.torrent.copy();
                },
              ),
              IconButton(
                icon: Icon(FluentIcons.clipboard_link_24_regular),
                color: accentColor,
                tooltip: "复制并尝试打开磁力链接",
                iconSize: 20.0,
                onPressed: () {
                  record.magnet.launchApp();
                  record.magnet.copy();
                },
              ),
              IconButton(
                icon: Icon(FluentIcons.share_24_regular),
                color: accentColor,
                tooltip: "分享",
                iconSize: 20.0,
                onPressed: () {
                  record.magnet.share();
                },
              ),
              IconButton(
                icon: Icon(FluentIcons.star_24_regular),
                color: accentColor,
                tooltip: "收藏",
                iconSize: 20.0,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
