import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/models/bangumi_details_model.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@immutable
class BangumiDetailsPageSelectedSubgroupList extends StatelessWidget {
  final ScrollController scrollController;

  BangumiDetailsPageSelectedSubgroupList(
      {Key key, @required this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).accentColor;
    final TextStyle tagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    final bangumiDetailsModel =
        Provider.of<BangumiDetailsModel>(context, listen: false);
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowGlow();
        return false;
      },
      child: Selector<BangumiDetailsModel, SubgroupBangumi>(
        selector: (_, model) => model.subgroupBangumi,
        shouldRebuild: (pre, next) => pre != next,
        builder: (context, subgroupBangumi, child) {
          if (subgroupBangumi == null) return Container();
          return SmartRefresher(
            controller: bangumiDetailsModel.refreshController,
            enablePullDown: false,
            enablePullUp: true,
            onLoading: bangumiDetailsModel.loadSubgroupList,
            footer: Indicator.footer(context, accentColor, bottom: 16.0),
            child: ListView.builder(
              controller: scrollController,
              itemCount: subgroupBangumi.records.length,
              itemBuilder: (context, ind) {
                final record = subgroupBangumi.records[ind];
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          ],
                        ),
                        padding: EdgeInsets.only(
                          top: 8.0,
                          bottom: 4.0,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
