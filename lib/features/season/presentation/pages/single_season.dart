import 'package:easy_refresh/easy_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFAutoImport()
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:mikan/core/models/bangumi_row.dart';
@FFAutoImport()
import 'package:mikan/core/models/season.dart';
import 'package:mikan/core/widgets/sliver_bangumi_list.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/features/season/application/season_provider.dart';

@FFRoute(name: '/season')
class SingleSeasonPage extends ConsumerWidget {
  const SingleSeasonPage({super.key, required this.season});

  final Season season;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final seasonAsync = ref.watch(seasonProvider(season));

    return Scaffold(
      body: seasonAsync.when(
        data: (seasonData) {
          return EasyRefresh(
            header: defaultHeader,
            onRefresh: () => ref.refresh(seasonProvider(season).future),
            child: CustomScrollView(
              slivers: [
                SliverPinnedAppBar(title: season.title),
                ...List.generate(seasonData.bangumiRows.length, (index) {
                  final BangumiRow bangumiRow = seasonData.bangumiRows[index];
                  return MultiSliver(
                    pushPinnedChildren: true,
                    children: [
                      _buildWeekSection(theme, bangumiRow),
                      ProviderScope(
                        overrides: [bangumisListProvider.overrideWithValue(bangumiRow.bangumis)],
                        child: const SliverBangumiList(),
                      ),
                    ],
                  );
                }),
                sliverGapH24WithNavBarHeight(context),
              ],
            ),
          );
        },
        loading: () => const Center(child: ExpressiveLoadingIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
      ),
    );
  }

  Widget _buildWeekSection(ThemeData theme, BangumiRow bangumiRow) {
    final simple = [
      if (bangumiRow.updatedNum > 0) '🚀 ${bangumiRow.updatedNum}部',
      if (bangumiRow.subscribedUpdatedNum > 0) '💖 ${bangumiRow.subscribedUpdatedNum}部',
      if (bangumiRow.subscribedNum > 0) '❤ ${bangumiRow.subscribedNum}部',
      '🎬 ${bangumiRow.num}部',
    ].join('，');
    final full = [
      if (bangumiRow.updatedNum > 0) '更新${bangumiRow.updatedNum}部',
      if (bangumiRow.subscribedUpdatedNum > 0) '订阅更新${bangumiRow.subscribedUpdatedNum}部',
      if (bangumiRow.subscribedNum > 0) '订阅${bangumiRow.subscribedNum}部',
      '共${bangumiRow.num}部',
    ].join('，');

    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
          height: 48.0,
          child: Row(
            children: <Widget>[
              Expanded(child: Text(bangumiRow.name, style: theme.textTheme.titleMedium)),
              Tooltip(
                message: full,
                child: Text(simple, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
