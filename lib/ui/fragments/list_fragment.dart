import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/providers/models/list_model.dart';
import 'package:mikan_flutter/ui/components/complex_record_item.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@immutable
class ListFragment extends StatelessWidget {
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
    final Color backgroundColor = Theme.of(context).backgroundColor;
    final Color scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;
    final ListModel listModel = Provider.of(context, listen: false);
    return Scaffold(
      body: NotificationListener(
        onNotification: (notification) {
          if (notification is OverscrollIndicatorNotification) {
            notification.disallowGlow();
          } else if (notification is ScrollUpdateNotification) {
            if (notification.depth == 0) {
              final double offset = notification.metrics.pixels;
              context.read<ListModel>().hasScrolled = offset > 0;
            }
          }
          return true;
        },
        child: Column(
          children: <Widget>[
            Selector<ListModel, bool>(
              selector: (_, model) => model.hasScrolled,
              builder: (_, hasScrolled, __) {
                return AnimatedContainer(
                  decoration: BoxDecoration(
                    color:
                        hasScrolled ? backgroundColor : scaffoldBackgroundColor,
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
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: 16.0 + Sz.statusBarHeight,
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  duration: Duration(milliseconds: 240),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "最新发布",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
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
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: length,
                        itemBuilder: (context, index) {
                          final RecordItem record = records[index];
                          return Selector<ListModel, int>(
                            selector: (_, model) => model.tapRecordItemIndex,
                            shouldRebuild: (pre, next) => pre != next,
                            builder: (context, scaleIndex, child) {
                              final Matrix4 transform = scaleIndex == index
                                  ? Matrix4.diagonal3Values(0.9, 0.9, 1)
                                  : Matrix4.identity();
                              return ComplexRecordItem(
                                index: index,
                                record: record,
                                accentColor: accentColor,
                                primaryColor: primaryColor,
                                backgroundColor: backgroundColor,
                                fileTagStyle: fileTagStyle,
                                titleTagStyle: titleTagStyle,
                                transform: transform,
                                onTap: () {},
                                onTapStart: () {
                                  context
                                      .read<ListModel>()
                                      .tapRecordItemIndex =
                                      index;
                                },
                                onTapEnd: () {
                                  context
                                      .read<ListModel>()
                                      .tapRecordItemIndex =
                                  -1;
                                },
                              );
                            },
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
