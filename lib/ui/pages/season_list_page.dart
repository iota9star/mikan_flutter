import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/season_bangumi_rows.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/op_model.dart';
import 'package:mikan_flutter/providers/season_list_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:mikan_flutter/widget/sliver_pinned_header.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliver_tools/sliver_tools.dart';

@FFRoute(
  name: "season-list",
  routeName: "/season-list",
  argumentImports: [
    "import 'package:mikan_flutter/model/year_season.dart';",
    "import 'package:mikan_flutter/model/season_gallery.dart';",
    "import 'package:flutter/material.dart';",
  ],
)
@immutable
class SeasonListPage extends StatelessWidget {
  final List<YearSeason> years;

  const SeasonListPage({Key? key, required this.years}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => SeasonListModel(years),
        child: Builder(builder: (context) {
          final seasonListModel =
              Provider.of<SeasonListModel>(context, listen: false);
          return Scaffold(
            body: Selector<SeasonListModel, List<SeasonBangumis>>(
              selector: (_, model) => model.seasonBangumis,
              shouldRebuild: (pre, next) => pre.ne(next),
              builder: (context, seasons, __) {
                return SmartRefresher(
                  controller: seasonListModel.refreshController,
                  header: WaterDropMaterialHeader(
                    backgroundColor: theme.secondary,
                    color: theme.secondary.isDark ? Colors.white : Colors.black,
                    distance: Screen.statusBarHeight + 42.0,
                  ),
                  footer: Indicator.footer(
                    context,
                    theme.secondary,
                    bottom: 16.0,
                  ),
                  enablePullDown: true,
                  enablePullUp: true,
                  onRefresh: seasonListModel.refresh,
                  onLoading: seasonListModel.loadMore,
                  child: _buildContentWrapper(context, theme, seasons),
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
    final List<SeasonBangumis> seasons,
  ) {
    return CustomScrollView(
      slivers: [
        _buildHeader(theme),
        ...List.generate(seasons.length, (index) {
          final SeasonBangumis seasonBangumis = seasons[index];
          final String seasonTitle = seasonBangumis.season.title;
          return MultiSliver(
            pushPinnedChildren: true,
            children: <Widget>[
              _buildSeasonSection(theme, seasonTitle),
              ...List.generate(
                seasonBangumis.bangumiRows.length,
                (ind) {
                  final BangumiRow bangumiRow = seasonBangumis.bangumiRows[ind];
                  return MultiSliver(
                    pushPinnedChildren: true,
                    children: <Widget>[
                      _buildBangumiRowSection(theme, bangumiRow),
                      BangumiSliverGridFragment(
                        flag: seasonTitle,
                        padding: edge16,
                        bangumis: bangumiRow.bangumis,
                        handleSubscribe: (bangumi, flag) {
                          context.read<OpModel>().subscribeBangumi(
                            bangumi.id,
                            bangumi.subscribed,
                            onSuccess: () {
                              bangumi.subscribed = !bangumi.subscribed;
                              context.read<OpModel>().subscribeChanged(flag);
                            },
                            onError: (msg) {
                              "订阅失败：$msg".toast();
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSeasonSection(final ThemeData theme, final String seasonTitle) {
    return SliverPinnedToBoxAdapter(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: edgeH16T8,
          child: Text(
            seasonTitle,
            style: const TextStyle(
              fontSize: 20,
              height: 1.25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBangumiRowSection(
    final ThemeData theme,
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
    return SliverPinnedToBoxAdapter(
      child: Transform.translate(
        offset: offsetY_2,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: edgeH16V8,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  bangumiRow.name,
                  style: textStyle18B,
                ),
              ),
              Tooltip(
                message: full,
                child: Text(
                  simple,
                  style: TextStyle(
                    color: theme.textTheme.subtitle1?.color,
                    fontSize: 14.0,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(final ThemeData theme) {
    final it = ColorTween(
      begin: theme.backgroundColor,
      end: theme.scaffoldBackgroundColor,
    );
    return SimpleSliverPinnedHeader(
      builder: (context, ratio) {
        final ic = it.transform(ratio);
        return Row(
          children: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minWidth: 32.0,
              padding: EdgeInsets.zero,
              shape: circleShape,
              color: ic,
              child: const Icon(
                FluentIcons.chevron_left_24_regular,
                size: 16.0,
              ),
            ),
            sizedBoxW12,
            Expanded(
              child: Text(
                "季度番组",
                style: TextStyle(
                  fontSize: 30.0 - (ratio * 6.0),
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
