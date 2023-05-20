import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../internal/extension.dart';
import '../../model/bangumi_row.dart';
@FFArgumentImport()
import '../../model/season.dart';
import '../../providers/op_model.dart';
import '../../providers/season_model.dart';
import '../../topvars.dart';
import '../../widget/sliver_pinned_header.dart';
import '../fragments/bangumi_sliver_grid.dart';

@FFRoute(name: '/season')
class SingleSeasonPage extends StatelessWidget {
  const SingleSeasonPage({super.key, required this.season});

  final Season season;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => SeasonModel(season),
      child: Builder(
        builder: (context) {
          final seasonModel = Provider.of<SeasonModel>(context, listen: false);
          return Scaffold(
            body: Selector<SeasonModel, List<BangumiRow>>(
              selector: (_, model) => model.bangumiRows,
              shouldRebuild: (pre, next) => pre.ne(next),
              builder: (_, bangumiRows, __) {
                return EasyRefresh(
                  refreshOnStart: true,
                  header: defaultHeader,
                  onRefresh: seasonModel.refresh,
                  child: CustomScrollView(
                    slivers: [
                      SliverPinnedAppBar(title: season.title),
                      ...List.generate(bangumiRows.length, (index) {
                        final BangumiRow bangumiRow = bangumiRows[index];
                        return MultiSliver(
                          pushPinnedChildren: true,
                          children: [
                            _buildWeekSection(theme, bangumiRow),
                            BangumiSliverGridFragment(
                              bangumis: bangumiRow.bangumis,
                              handleSubscribe: (bangumi, flag) {
                                context.read<OpModel>().subscribeBangumi(
                                  bangumi.id,
                                  bangumi.subscribed,
                                  onSuccess: () {
                                    bangumi.subscribed = !bangumi.subscribed;
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
                      }),
                      sliverSizedBoxH24WithNavBarHeight(context),
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

  Widget _buildWeekSection(
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
        offset: offsetY_1,
        child: Container(
          padding: edgeH24V8,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
          ),
          height: 48.0,
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
