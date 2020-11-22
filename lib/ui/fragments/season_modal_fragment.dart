import 'package:extended_sliver/extended_sliver.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

@immutable
class SeasonModalFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).accentColor;
    final Color backgroundColor = Theme.of(context).backgroundColor;
    final Color scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;
    return Material(
      color: scaffoldBackgroundColor,
      child: NotificationListener(
        onNotification: (notification) {
          if (notification is OverscrollIndicatorNotification) {
            notification.disallowGlow();
          }
          return true;
        },
        child: CustomScrollView(
          shrinkWrap: true,
          controller: ModalScrollController.of(context),
          slivers: [
            _buildHeader(context, backgroundColor, scaffoldBackgroundColor),
            _buildSeasonItemList(
              primaryColor,
              accentColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    final BuildContext context,
    final Color backgroundColor,
    final Color scaffoldBackgroundColor,
  ) {
    return SliverPinnedToBoxAdapter(
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.024),
              offset: Offset(0, 1),
              blurRadius: 3.0,
              spreadRadius: 3.0,
            ),
          ],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
        ),
        duration: Duration(milliseconds: 240),
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "年度番组",
                style: TextStyle(
                  fontSize: 24,
                  height: 1.25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.seasonList.name,
                  arguments: Routes.seasonList.d(
                    years: context.read<IndexModel>().years,
                  ),
                );
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: Icon(
                FluentIcons.chevron_right_24_regular,
                size: 24.0,
              ),
              minWidth: 0,
              color: scaffoldBackgroundColor,
              shape: CircleBorder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonItem(
    final Color primaryColor,
    final Color accentColor,
    final Season season,
  ) {
    return Flexible(
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Selector<IndexModel, Season>(
            selector: (_, model) => model.selectedSeason,
            shouldRebuild: (pre, next) => pre != next,
            builder: (context, selectedSeason, _) {
              final Color color = season.title == selectedSeason.title
                  ? primaryColor
                  : accentColor;
              return Tooltip(
                message: season.title,
                child: MaterialButton(
                  minWidth: 0,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    season.season,
                    style: TextStyle(
                      fontSize: 18.0,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  color: color.withOpacity(0.12),
                  elevation: 0,
                  onPressed: () {
                    context.read<IndexModel>().loadSeason(season);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonItemList(
    final Color primaryColor,
    final Color accentColor,
  ) {
    return SliverPadding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 24.0,
        bottom: 16.0 + Sz.navBarHeight,
      ),
      sliver: Selector<IndexModel, List<YearSeason>>(
        selector: (_, model) => model.years,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, years, __) {
          if (years.isNullOrEmpty) return SliverToBoxAdapter();
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final YearSeason year = years[index];
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      year.year,
                      style: TextStyle(
                        fontSize: 20.0,
                        height: 1.25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 12.0),
                    ...List.generate(
                      4,
                      (index) {
                        if (year.seasons.length > index) {
                          return _buildSeasonItem(
                            primaryColor,
                            accentColor,
                            year.seasons[index],
                          );
                        } else {
                          return Flexible(
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
