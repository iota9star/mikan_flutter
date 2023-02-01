import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/icon_button.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

@immutable
class SelectSeasonFragment extends StatelessWidget {
  const SelectSeasonFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indexModel = Provider.of<IndexModel>(context, listen: false);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: CustomScrollView(
        shrinkWrap: true,
        controller: ModalScrollController.of(context),
        slivers: [
          _buildHeader(context, theme, indexModel),
          _buildSeasonItemList(theme, indexModel),
        ],
      ),
    );
  }

  Widget _buildHeader(
    final BuildContext context,
    final ThemeData theme,
    final IndexModel indexModel,
  ) {
    return SliverPinnedToBoxAdapter(
      child: Container(
        padding: edge16,
        decoration: BoxDecoration(color: theme.colorScheme.background),
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                "年度番组",
                style: textStyle20B,
              ),
            ),
            RightArrowButton(
              color: theme.scaffoldBackgroundColor,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.seasonList.name,
                  arguments: Routes.seasonList.d(years: indexModel.years),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonItem(
    final ThemeData theme,
    final Season season,
    final IndexModel indexModel,
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
              final Color color = season.title == selectedSeason?.title
                  ? theme.primary
                  : theme.secondary;
              return Tooltip(
                message: season.title,
                child: RippleTap(
                  color: color.withOpacity(0.1),
                  onTap: () {
                    indexModel.loadSeason(season);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      season.season,
                      style: TextStyle(
                        fontSize: 18.0,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        color: color,
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
    final ThemeData theme,
    final IndexModel indexModel,
  ) {
    return SliverPadding(
      padding: edgeHT16B24WithNavbarHeight,
      sliver: Selector<IndexModel, List<YearSeason>>(
        selector: (_, model) => model.years,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, years, __) {
          if (years.isNullOrEmpty) return emptySliverToBoxAdapter;
          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final YearSeason year = years[index];
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 64.0,
                      child: Text(
                        year.year,
                        style: textStyle20B,
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
            gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 8.0,
              mainAxisExtent: 40.0,
            ),
          );
        },
      ),
    );
  }
}
