import 'package:easy_refresh/easy_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFAutoImport()
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:mikan/core/models/bangumi_row.dart';
@FFAutoImport()
import 'package:mikan/core/models/year_season.dart';
import 'package:mikan/core/widgets/sliver_bangumi_list.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/features/season/application/season_list_provider.dart';

@FFRoute(name: '/bangumi/season')
@immutable
class SeasonBangumi extends ConsumerWidget {
  const SeasonBangumi({super.key, required this.years});

  final List<YearSeason> years;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Builder(
        builder: (context) {
          // Watch the AsyncValue and handle loading/error/data states
          final stateAsync = ref.watch(seasonListProvider(years));
          return stateAsync.when(
            loading: () => const Center(child: ExpressiveLoadingIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败: $error'),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: () => ref.read(seasonListProvider(years).notifier).refresh(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
            data: (state) {
              final seasons = state.bangumis;
              return EasyRefresh(
                header: defaultHeader,
                footer: defaultFooter(context),
                refreshOnStart: true,
                onRefresh: () => ref.read(seasonListProvider(years).notifier).refresh(),
                onLoad: () => ref.read(seasonListProvider(years).notifier).loadMore(),
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
                          ...List.generate(seasonBangumis.bangumiRows.length, (ind) {
                            final bangumiRow = seasonBangumis.bangumiRows[ind];
                            return MultiSliver(
                              pushPinnedChildren: true,
                              children: <Widget>[
                                _buildBangumiRowSection(theme, bangumiRow),
                                ProviderScope(
                                  overrides: [bangumisListProvider.overrideWithValue(bangumiRow.bangumis)],
                                  child: const SliverBangumiList(),
                                ),
                              ],
                            );
                          }),
                        ],
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSeasonSection(ThemeData theme, String seasonTitle) {
    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(seasonTitle, style: theme.textTheme.titleMedium),
        ),
      ),
    );
  }

  Widget _buildBangumiRowSection(ThemeData theme, BangumiRow bangumiRow) {
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
        offset: offsetY_2,
        child: Container(
          color: theme.colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
