import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/delegate.dart';
import '../../internal/extension.dart';
import '../../internal/kit.dart';
import '../../mikan_routes.dart';
import '../../model/season.dart';
import '../../model/year_season.dart';
import '../../providers/index_model.dart';
import '../../topvars.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/sliver_pinned_header.dart';

@immutable
class SelectSeasonFragment extends StatelessWidget {
  const SelectSeasonFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indexModel = Provider.of<IndexModel>(context, listen: false);
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
                    arguments: Routes.bangumiSeason.d(years: indexModel.years),
                  );
                },
                icon: const Icon(Icons.east_rounded),
              ),
            ],
          ),
          _buildSeasonItemList(context, theme, indexModel),
          sliverSizedBoxH24WithNavBarHeight(context),
        ],
      ),
    );
  }

  Widget _buildSeasonItem(
    ThemeData theme,
    Season season,
    IndexModel indexModel,
  ) {
    return Flexible(
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Padding(
          padding: edgeH4,
          child: Selector<IndexModel, Season?>(
            selector: (_, model) => model.selectedSeason,
            shouldRebuild: (pre, next) => pre != next,
            builder: (context, selectedSeason, _) {
              final selected = season.title == selectedSeason?.title;
              return Tooltip(
                message: season.title,
                child: RippleTap(
                  color: selected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: borderRadius6,
                  onTap: () {
                    Navigator.pop(context);
                    indexModel.selectSeason(season);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      season.season,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: selected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
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

  Widget _buildSeasonItemList(
    BuildContext context,
    ThemeData theme,
    IndexModel indexModel,
  ) {
    return SliverPadding(
      padding: edgeH24V8,
      sliver: Selector<IndexModel, List<YearSeason>>(
        selector: (_, model) => model.years,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, years, __) {
          if (years.isNullOrEmpty) {
            return emptySliverToBoxAdapter;
          }
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              crossAxisSpacing: context.margins,
              mainAxisSpacing: context.margins,
              mainAxisExtent: 40.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final YearSeason year = years[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 78.0,
                      child: Text(
                        year.year,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    sizedBoxW12,
                    ...List.generate(
                      4,
                      (index) {
                        if (year.seasons.length > index) {
                          return _buildSeasonItem(
                            theme,
                            year.seasons[index],
                            indexModel,
                          );
                        } else {
                          return const Flexible(
                            child: FractionallySizedBox(widthFactor: 1),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
              childCount: years.length,
            ),
          );
        },
      ),
    );
  }
}
