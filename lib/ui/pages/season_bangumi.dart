import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../internal/extension.dart';
import '../../model/bangumi_row.dart';
import '../../model/season_bangumi_rows.dart';
@FFArgumentImport()
import '../../model/year_season.dart';
import '../../providers/op_model.dart';
import '../../providers/season_list_model.dart';
import '../../topvars.dart';
import '../../widget/sliver_pinned_header.dart';
import '../fragments/bangumi_sliver_grid.dart';

@FFRoute(name: '/bangumi/season')
@immutable
class SeasonBangumi extends StatelessWidget {
  const SeasonBangumi({super.key, required this.years});

  final List<YearSeason> years;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => SeasonListModel(years),
        child: Builder(
          builder: (context) {
            final seasonListModel =
                Provider.of<SeasonListModel>(context, listen: false);
            return Scaffold(
              body: Selector<SeasonListModel, List<SeasonBangumis>>(
                selector: (_, model) => model.bangumis,
                shouldRebuild: (pre, next) => pre.ne(next),
                builder: (context, seasons, __) {
                  return EasyRefresh(
                    header: defaultHeader,
                    footer: defaultFooter(context),
                    refreshOnStart: true,
                    onRefresh: seasonListModel.refresh,
                    onLoad: seasonListModel.loadMore,
                    child: CustomScrollView(
                      slivers: [
                        const SliverPinnedAppBar(title: '季度番组'),
                        ...List.generate(seasons.length, (index) {
                          final seasonBangumis = seasons[index];
                          final seasonTitle = seasonBangumis.season.title;
                          return MultiSliver(
                            pushPinnedChildren: true,
                            children: <Widget>[
                              _buildSeasonSection(theme, seasonTitle),
                              ...List.generate(
                                seasonBangumis.bangumiRows.length,
                                (ind) {
                                  final bangumiRow =
                                      seasonBangumis.bangumiRows[ind];
                                  return MultiSliver(
                                    pushPinnedChildren: true,
                                    children: <Widget>[
                                      _buildBangumiRowSection(
                                        theme,
                                        bangumiRow,
                                      ),
                                      BangumiSliverGridFragment(
                                        flag: seasonTitle,
                                        bangumis: bangumiRow.bangumis,
                                        handleSubscribe: (bangumi, flag) {
                                          context
                                              .read<OpModel>()
                                              .subscribeBangumi(
                                            bangumi.id,
                                            bangumi.subscribed,
                                            onSuccess: () {
                                              bangumi.subscribed =
                                                  !bangumi.subscribed;
                                              context
                                                  .read<OpModel>()
                                                  .subscribeChanged(flag);
                                            },
                                            onError: (msg) {
                                              '订阅失败：$msg'.toast();
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
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSeasonSection(ThemeData theme, String seasonTitle) {
    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.colorScheme.background,
          padding: edgeH24T8,
          child: Text(
            seasonTitle,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildBangumiRowSection(
    ThemeData theme,
    BangumiRow bangumiRow,
  ) {
    final simple = [
      if (bangumiRow.updatedNum > 0) '🚀 ${bangumiRow.updatedNum}部',
      if (bangumiRow.subscribedUpdatedNum > 0)
        '💖 ${bangumiRow.subscribedUpdatedNum}部',
      if (bangumiRow.subscribedNum > 0) '❤ ${bangumiRow.subscribedNum}部',
      '🎬 ${bangumiRow.num}部'
    ].join('，');
    final full = [
      if (bangumiRow.updatedNum > 0) '更新${bangumiRow.updatedNum}部',
      if (bangumiRow.subscribedUpdatedNum > 0)
        '订阅更新${bangumiRow.subscribedUpdatedNum}部',
      if (bangumiRow.subscribedNum > 0) '订阅${bangumiRow.subscribedNum}部',
      '共${bangumiRow.num}部'
    ].join('，');
    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_2,
        child: Container(
          color: theme.colorScheme.background,
          padding: edgeH24V8,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  bangumiRow.name,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Tooltip(
                message: full,
                child: Text(
                  simple,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
