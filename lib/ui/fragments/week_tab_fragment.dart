import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/ext/screen.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

typedef OnTabChange = void Function(int index);

class WeekTabFragment extends StatefulWidget {
  final List<BangumiRow> bangumiRows;
  final bool loading;
  final OnTabChange onTabChange;
  final Widget header;
  final Widget loader;

  const WeekTabFragment({
    Key key,
    @required this.bangumiRows,
    this.onTabChange,
    @required this.header,
    this.loading,
    this.loader,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => WeekTabFragmentState();
}

class WeekTabFragmentState extends State<WeekTabFragment>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  TabController _tabController;

  _tabChangeCallback() {
    widget.onTabChange(_tabController.index);
  }

  @override
  void dispose() {
    this._tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!widget.loading) {
      if (_tabController == null) {
        _tabController =
            TabController(length: widget.bangumiRows.length, vsync: this);
        _tabController.addListener(_tabChangeCallback);
      } else if (_tabController.length != widget.bangumiRows.length) {
        _tabController.removeListener(_tabChangeCallback);
        _tabController.dispose();
        _tabController =
            TabController(length: widget.bangumiRows.length, vsync: this);
        _tabController.addListener(_tabChangeCallback);
      }
    }
    final Color accentColor = Theme.of(context).accentColor;
    final Color titleColor = Theme.of(context).textTheme.headline6.color;
    final int bangumiWidth =
        ((Sz.screenWidth - 4 * 16) / 3 * Sz.devicePixelRatio).toInt();
    return Column(
      children: widget.loading
          ? <Widget>[
              widget.header,
              Expanded(child: widget.loader),
            ]
          : <Widget>[
              widget.header,
              TabBar(
                controller: _tabController,
                labelStyle: TextStyle(
                  fontSize: 18,
                  fontFamily: 'zcoolxw',
                ),
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: accentColor,
                unselectedLabelColor: titleColor,
                isScrollable: true,
                indicator: BoxDecoration(),
                tabs: widget.bangumiRows
                    .map((e) => Tab(child: Text(e.name)))
                    .toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: widget.bangumiRows.map((e) {
                    return buildBangumiList(e, bangumiWidth, accentColor);
                  }).toList(),
                ),
              )
            ],
    );
  }

  Widget buildBangumiList(
    BangumiRow e,
    int bangumiWidth,
    Color accentColor,
  ) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowGlow();
        return false;
      },
      child: WaterfallFlow.builder(
        key: PageStorageKey(e.name),
        padding:
            EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
        itemCount: e.bangumis.length,
        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 12,
          mainAxisSpacing: 20,
          crossAxisCount: 3,
          collectGarbage: (List<int> garbages) {
            garbages.forEach((it) {
              CachedNetworkImageProvider(e.bangumis[it].cover).evict();
            });
          },
        ),
        itemBuilder: (BuildContext context, int index) {
          final Bangumi bangumi = e.bangumis[index];
          return buildBangumiItem(bangumi, bangumiWidth, accentColor);
        },
      ),
    );
  }

  Container buildBangumiItem(
    Bangumi bangumi,
    int bangumiWidth,
    Color accentColor,
  ) {
    final TextStyle tagStyle = TextStyle(
      fontSize: 10,
      color: accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    final List<Widget> tags = [
      if (bangumi.subscribed)
        Container(
          margin: EdgeInsets.only(right: 4.0, bottom: 4.0),
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Text(
            "已订阅",
            style: tagStyle,
          ),
        ),
      if (bangumi.num > 0)
        Container(
          margin: EdgeInsets.only(right: 4.0, bottom: 4.0),
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Text(
            bangumi.num.toString(),
            style: tagStyle,
          ),
        ),
      Container(
        margin: EdgeInsets.only(right: 4.0, bottom: 4.0),
        padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.87),
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Text(
          bangumi.updateAt,
          style: tagStyle,
        ),
      ),
    ];
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 325 / 528,
            child: CachedNetworkImage(
              imageUrl: "${bangumi.cover}?width=$bangumiWidth&format=jpg",
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8.0,
                      color: Colors.black.withAlpha(24),
                    )
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    colorFilter: bangumi.grey
                        ? ColorFilter.mode(Colors.grey, BlendMode.color)
                        : null,
                  ),
                ),
              ),
              progressIndicatorBuilder: (context, url, downloadProgress) {
                return Center(
                  child: CircularProgressIndicator(
                    value: downloadProgress.progress,
                  ),
                );
              },
              errorWidget: (_, __, ___) {
                return Center(
                  child: Image.asset("assets/mikan.png"),
                );
              },
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Wrap(
            children: tags,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 4,
                height: 10,
                margin: EdgeInsets.only(top: 4.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bangumi.grey ? Colors.grey : accentColor,
                      accentColor.withOpacity(0.16), // 灰蓝也还行
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  bangumi.name,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
