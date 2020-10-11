import 'package:ant_icons/ant_icons.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:flutter/material.dart';
import 'package:mikan_flutter/model/record_item.dart';

class BangumiDetailsPageTabItem extends StatefulWidget {
  final int index;
  final List<RecordItem> records;

  BangumiDetailsPageTabItem({Key key, this.index, this.records})
      : super(key: key);

  @override
  _BangumiDetailsPageTabItemState createState() =>
      _BangumiDetailsPageTabItemState();
}

class _BangumiDetailsPageTabItemState extends State<BangumiDetailsPageTabItem>
    with AutomaticKeepAliveClientMixin {
  String _keyStr;

  @override
  void initState() {
    super.initState();
    _keyStr = "selected_tab_${widget.index}";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Color accentColor = Theme.of(context).accentColor;
    final TextStyle tagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    return extended.NestedScrollViewInnerScrollPositionKeyWidget(
      Key(_keyStr),
      ListView.builder(
        key: PageStorageKey<String>(_keyStr),
        itemCount: widget.records.length,
        itemBuilder: (context, ind) {
          final record = widget.records[ind];
          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "$ind => " + record.title,
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
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
