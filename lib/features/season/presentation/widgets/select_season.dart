import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mikan/features/home/application/index_provider.dart';
import 'package:mikan/app/routing/mikan_routes.dart';
import 'package:mikan/core/common/delegate.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/kit.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/core/models/season.dart';
import 'package:mikan/core/models/year_season.dart';
import 'package:mikan/core/widgets/ripple_tap.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';

@immutable
class SelectSeasonFragment extends ConsumerWidget {
  const SelectSeasonFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final indexAsync = ref.watch(indexProvider);

    return indexAsync.when(
      data: (indexData) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPinnedAppBar(
                title: '年度番组',
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.bangumiSeason.name,
                        arguments: Routes.bangumiSeason.d(years: indexData.years),
                      );
                    },
                    icon: const Icon(Icons.east_rounded),
                  ),
                ],
              ),
              _buildSeasonItemList(context, ref, theme, indexData),
              sliverGapH24WithNavBarHeight(context),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: ExpressiveLoadingIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('加载失败: $error'))),
    );
  }

  Widget _buildSeasonItem(BuildContext context, WidgetRef ref, ThemeData theme, Season season, Season? selectedSeason) {
    return Flexible(
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Builder(
            builder: (context) {
              final selected = season.title == selectedSeason?.title;
              return Tooltip(
                message: season.title,
                child: RippleTap(
                  color: selected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(indexProvider.notifier).selectSeason(season);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Text(
                      season.season,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: selected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonItemList(BuildContext context, WidgetRef ref, ThemeData theme, IndexData indexData) {
    final years = indexData.years;
    final selectedSeason = indexData.selectedSeason;

    if (years.isNullOrEmpty) {
      return emptySliverToBoxAdapter;
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMinCrossAxisExtent(
          minCrossAxisExtent: 400.0,
          crossAxisSpacing: context.margins,
          mainAxisSpacing: context.margins,
          mainAxisExtent: 40.0,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final YearSeason year = years[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 78.0, child: Text(year.year, style: theme.textTheme.titleLarge)),
              const Gap(12),
              ...List.generate(4, (index) {
                if (year.seasons.length > index) {
                  return _buildSeasonItem(context, ref, theme, year.seasons[index], selectedSeason);
                } else {
                  return const Flexible(child: FractionallySizedBox(widthFactor: 1));
                }
              }),
            ],
          );
        }, childCount: years.length),
      ),
    );
  }
}
