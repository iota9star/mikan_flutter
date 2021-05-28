import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/season_gallery.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/subscribed_model.dart';
import 'package:mikan_flutter/providers/subscribed_season_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliver_tools/sliver_tools.dart';

@FFRoute(
  name: "subscribed-season",
  routeName: "subscribed-season",
  argumentImports: [
    "import 'package:mikan_flutter/model/year_season.dart';",
    "import 'package:mikan_flutter/model/season_gallery.dart';",
    "import 'package:flutter/material.dart';",
  ],
)
@immutable
class SubscribedSeasonPage extends StatelessWidget {
  final List<YearSeason> years;

  final List<SeasonGallery> galleries;

  const SubscribedSeasonPage({
    Key? key,
    required this.years,
    required this.galleries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => SubscribedSeasonModel(this.years, this.galleries),
        child: Builder(builder: (context) {
          final SubscribedSeasonModel seasonSubscribedModel =
              Provider.of<SubscribedSeasonModel>(context, listen: false);
          return Scaffold(
            body: NotificationListener(
              onNotification: (notification) {
                if (notification is OverscrollIndicatorNotification) {
                  notification.disallowGlow();
                } else if (notification is ScrollUpdateNotification) {
                  if (notification.depth == 0) {
                    final double offset = notification.metrics.pixels;
                    seasonSubscribedModel.hasScrolled = offset > 0.0;
                  }
                }
                return true;
              },
              child: Selector<SubscribedSeasonModel, List<SeasonGallery>>(
                selector: (_, model) => model.galleries,
                shouldRebuild: (pre, next) => pre.ne(next),
                builder: (context, galleries, __) {
                  return SmartRefresher(
                    controller: seasonSubscribedModel.refreshController,
                    header: WaterDropMaterialHeader(
                      backgroundColor: theme.accentColor,
                      color: theme.accentColor.computeLuminance() < 0.5
                          ? Colors.white
                          : Colors.black,
                      distance: Sz.statusBarHeight + 42.0,
                    ),
                    footer: Indicator.footer(
                      context,
                      theme.accentColor,
                      bottom: 16.0,
                    ),
                    enablePullDown: true,
                    enablePullUp: true,
                    onRefresh: seasonSubscribedModel.refresh,
                    onLoading: seasonSubscribedModel.loadMore,
                    child: _buildContentWrapper(
                      context,
                      theme,
                      galleries,
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
    final BuildContext context,
    final ThemeData theme,
    final List<SeasonGallery> galleries,
  ) {
    return CustomScrollView(
      slivers: [
        _buildHeader(theme),
        if (galleries.isSafeNotEmpty)
          ...List.generate(
            galleries.length,
            (index) {
              final SeasonGallery gallery = galleries[index];
              return MultiSliver(
                pushPinnedChildren: true,
                children: <Widget>[
                  _buildSeasonSection(context, theme, gallery),
                  gallery.bangumis.isNullOrEmpty
                      ? _buildEmptySubscribedContainer(theme)
                      : BangumiSliverGridFragment(
                    flag: gallery.title,
                          padding: edge16,
                          bangumis: gallery.bangumis,
                          handleSubscribe: (bangumi, flag) {
                            context.read<SubscribedModel>().subscribeBangumi(
                              bangumi.id,
                              bangumi.subscribed,
                              onSuccess: () {
                                bangumi.subscribed = !bangumi.subscribed;
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
  }

  Widget _buildEmptySubscribedContainer(final ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        height: 240.0,
        margin: edgeH16V8,
        padding: edge24,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              theme.backgroundColor.withOpacity(0.72),
              theme.backgroundColor.withOpacity(0.9),
            ],
          ),
          borderRadius: borderRadius16,
        ),
        child: Center(
          child: Text(
            ">_< 您还没有订阅当前季度番组，快去添加订阅吧",
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonSection(
    final BuildContext context,
    final ThemeData theme,
    final SeasonGallery gallery,
  ) {
    return SliverPinnedToBoxAdapter(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        padding: edgeH16V8,
        child: Row(
          children: [
            Expanded(
              child: Text(
                gallery.title,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.season.name,
                  arguments: Routes.season.d(
                    season: Season(
                      year: gallery.year,
                      season: gallery.season,
                      title: gallery.title,
                      active: gallery.isCurrentSeason,
                    ),
                  ),
                );
              },
              color: theme.backgroundColor,
              minWidth: 0,
              height: 0,
              padding: EdgeInsets.all(5.0),
              shape: CircleBorder(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: Icon(
                FluentIcons.chevron_right_24_regular,
                size: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(final ThemeData theme) {
    return Selector<SubscribedSeasonModel, bool>(
      selector: (_, model) => model.hasScrolled,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, hasScrolled, __) {
        return SliverPinnedToBoxAdapter(
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: hasScrolled
                  ? theme.backgroundColor
                  : theme.scaffoldBackgroundColor,
              borderRadius: scrollHeaderBorderRadius(hasScrolled),
              boxShadow: scrollHeaderBoxShadow(hasScrolled),
            ),
            padding: edge16Header(),
            duration: dur240,
            child: Row(
              children: <Widget>[
                Text(
                  "季度订阅",
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
