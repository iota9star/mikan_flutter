import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/providers/models/list_model.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@immutable
class ListFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).accentColor;
    final TextStyle tagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    final ListModel listModel = Provider.of(context, listen: false);
    return Scaffold(
      body: NotificationListener(
        onNotification: (ScrollUpdateNotification notification) {
          listModel.notifyOffsetChange(notification.metrics.pixels);
          return true;
        },
        child: Column(
          children: <Widget>[
            Selector<ListModel, double>(
              selector: (_, model) => model.limit,
              builder: (_, limit, __) {
                final double offset = 1 - limit;
                final double dividerHeight = 2 + 4 * offset;
                final double containerHeight = 60 + 18 * offset + dividerHeight;
                final double indent = 16 * offset;
                return Container(
                  height: containerHeight + Sz.statusBarHeight + dividerHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          bottom: 12.0,
                        ),
                        child: Text(
                          "最新发布",
                          style: TextStyle(
                            fontSize: 28 + offset * 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        height: dividerHeight,
                        margin: EdgeInsets.only(left: indent, right: indent),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3 * offset),
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withOpacity(offset),
                              accentColor.withOpacity(limit)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: Selector<ListModel, int>(
                selector: (_, model) => model.recordsLength,
                shouldRebuild: (pre, next) => pre != next,
                builder: (_, length, ___) {
                  final List<RecordItem> records = listModel.records;
                  return SmartRefresher(
                    header: Indicator.header(context, accentColor, top: 16.0),
                    footer:
                        Indicator.footer(context, accentColor, bottom: 16.0),
                    enablePullDown: true,
                    enablePullUp: true,
                    controller: listModel.refreshController,
                    onRefresh: listModel.refresh,
                    onLoading: listModel.loadMore,
                    child: ListView.builder(
                        itemCount: length,
                        itemBuilder: (context, index) {
                          final RecordItem record = records[index];
                          return Selector<ListModel, int>(
                            selector: (_, model) => model.scaleIndex,
                            shouldRebuild: (pre, next) => pre != next,
                            builder: (context, scaleIndex, child) {
                              Matrix4 transform;
                              if (scaleIndex == index) {
                                transform =
                                    Matrix4.diagonal3Values(0.9, 0.9, 1);
                              } else {
                                transform = Matrix4.identity();
                              }
                              return AnimatedTapContainer(
                                transform: transform,
                                child: child,
                                onTap: () {
                                  // Navigator.pushNamed(
                                  //   context,
                                  //   Routes.mikanBangumiDetails,
                                  //   arguments: {
                                  //     "url": record.url,
                                  //     "cover": record.cover,
                                  //     "name": record.name,
                                  //     "title": record.title,
                                  //   },
                                  // );
                                },
                                onTapStart: () {
                                  context.read<ListModel>().scaleIndex = index;
                                },
                                onTapEnd: () {
                                  context.read<ListModel>().scaleIndex = -1;
                                },
                              );
                            },
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        record.title,
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
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
                                                color: accentColor
                                                    .withOpacity(0.87),
                                                borderRadius:
                                                    BorderRadius.circular(2.0),
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
                                                color: accentColor
                                                    .withOpacity(0.87),
                                                borderRadius:
                                                    BorderRadius.circular(2.0),
                                              ),
                                              child: Text(
                                                record.size,
                                                style: tagStyle,
                                              ),
                                            ),
                                            if (record.groups.isNotEmpty)
                                              ...List.generate(
                                                  record.groups.length,
                                                  (index) {
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
                                                    color: accentColor
                                                        .withOpacity(0.87),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.0),
                                                  ),
                                                  child: Text(
                                                    record.groups[index].name,
                                                    style: tagStyle,
                                                  ),
                                                );
                                              }),
                                            if (record.tags.isNotEmpty)
                                              ...List.generate(
                                                  record.tags.length, (index) {
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
                                                    color: accentColor
                                                        .withOpacity(0.87),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.0),
                                                  ),
                                                  child: Text(
                                                    record.tags[index],
                                                    style: tagStyle,
                                                  ),
                                                );
                                              })
                                          ],
                                        ),
                                        padding: EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 4.0,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(AntIcons.paper_clip),
                                            color: accentColor,
                                            tooltip: "打开详情页",
                                            iconSize: 20.0,
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: Icon(AntIcons.download),
                                            tooltip: "复制并尝试打开种子链接",
                                            color: accentColor,
                                            iconSize: 20.0,
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: Icon(AntIcons.link),
                                            color: accentColor,
                                            tooltip: "复制并尝试打开磁力链接",
                                            iconSize: 20.0,
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: Icon(AntIcons.share_alt),
                                            color: accentColor,
                                            tooltip: "分享",
                                            iconSize: 20.0,
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: Icon(AntIcons.star_outline),
                                            color: accentColor,
                                            tooltip: "收藏",
                                            iconSize: 20.0,
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
