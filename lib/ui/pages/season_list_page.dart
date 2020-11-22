import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/season_bangumi_rows.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/models/season_list_model.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@FFRoute(
  name: "season-list",
  routeName: "season-list",
  argumentImports: [
    "import 'package:mikan_flutter/model/year_season.dart';",
    "import 'package:mikan_flutter/model/season_gallery.dart';",
    "import 'package:flutter/material.dart';",
  ],
)
@immutable
class SeasonListPage extends StatelessWidget {
  final List<YearSeason> years;

  const SeasonListPage({Key key, this.years}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).accentColor;
    final Color accentTextColor =
        accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
    final Color backgroundColor = Theme.of(context).backgroundColor;
    final Color scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;
    final Color subtitleColor = Theme.of(context).textTheme.subtitle1.color;
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => SeasonListModel(this.years),
        child: Builder(builder: (context) {
          final SeasonListModel seasonListModel =
              Provider.of<SeasonListModel>(context, listen: false);
          return Scaffold(
            body: NotificationListener(
              onNotification: (notification) {
                if (notification is OverscrollIndicatorNotification) {
                  notification.disallowGlow();
                } else if (notification is ScrollUpdateNotification) {
                  if (notification.depth == 0) {
                    final double offset = notification.metrics.pixels;
                    seasonListModel.hasScrolled = offset > 0.0;
                  }
                }
                return true;
              },
              child: Selector<SeasonListModel, List<SeasonBangumis>>(
                selector: (_, model) => model.seasonBangumis,
                shouldRebuild: (pre, next) => pre.ne(next),
                builder: (context, seasons, __) {
                  return SmartRefresher(
                    controller: seasonListModel.refreshController,
                    header: WaterDropMaterialHeader(
                      backgroundColor: accentColor,
                      color: accentTextColor,
                      distance: Sz.statusBarHeight + 18.0,
                    ),
                    footer: Indicator.footer(
                      context,
                      accentColor,
                      bottom: 16.0 + Sz.navBarHeight,
                    ),
                    enablePullDown: true,
                    enablePullUp: true,
                    onRefresh: seasonListModel.refresh,
                    onLoading: seasonListModel.loadMore,
                    child: _buildContentWrapper(
                      backgroundColor,
                      scaffoldBackgroundColor,
                      subtitleColor,
                      seasons,
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContentWrapper(
    final Color backgroundColor,
    final Color scaffoldBackgroundColor,
    final Color subtitleColor,
    final List<SeasonBangumis> seasons,
  ) {
    return CustomScrollView(
      slivers: [
        _buildHeader(backgroundColor, scaffoldBackgroundColor),
        ...List.generate(seasons.length, (index) {
          final SeasonBangumis seasonBangumis = seasons[index];
          final String seasonTitle = seasonBangumis.season.title;
          return <Widget>[
            _buildSeasonSection(seasonTitle),
            ...List.generate(
              seasonBangumis.bangumiRows.length,
              (ind) {
                final BangumiRow bangumiRow = seasonBangumis.bangumiRows[ind];
                return <Widget>[
                  _buildBangumiRowSection(subtitleColor, bangumiRow),
                  BangumiSliverGridFragment(
                    flag: seasonTitle,
                    bangumis: bangumiRow.bangumis,
                  ),
                ];
              },
            ).expand((element) => element),
          ];
        }).expand((element) => element),
      ],
    );
  }

  Widget _buildSeasonSection(final String seasonTitle) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: 8.0,
        ),
        child: Text(
          seasonTitle,
          style: TextStyle(
            fontSize: 20,
            height: 1.25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBangumiRowSection(
    final Color subtitleColor,
    final BangumiRow bangumiRow,
  ) {
    final simple = [
      if (bangumiRow.updatedNum > 0) "🚀 ${bangumiRow.updatedNum}部",
      if (bangumiRow.subscribedUpdatedNum > 0)
        "💖 ${bangumiRow.subscribedUpdatedNum}部",
      if (bangumiRow.subscribedNum > 0) "❤ ${bangumiRow.subscribedNum}部",
      "🎬 ${bangumiRow.num}部"
    ].join("，");
    final full = [
      if (bangumiRow.updatedNum > 0) "更新${bangumiRow.updatedNum}部",
      if (bangumiRow.subscribedUpdatedNum > 0)
        "订阅更新${bangumiRow.subscribedUpdatedNum}部",
      if (bangumiRow.subscribedNum > 0) "订阅${bangumiRow.subscribedNum}部",
      "共${bangumiRow.num}部"
    ].join("，");
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: 8.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                bangumiRow.name,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Tooltip(
              message: full,
              child: Text(
                simple,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12.0,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    final Color backgroundColor,
    final Color scaffoldBackgroundColor,
  ) {
    return Selector<SeasonListModel, bool>(
      selector: (_, model) => model.hasScrolled,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, hasScrolled, __) {
        return SliverPinnedToBoxAdapter(
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: hasScrolled ? backgroundColor : scaffoldBackgroundColor,
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
              borderRadius: hasScrolled
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    )
                  : null,
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
                  "季度番组",
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
