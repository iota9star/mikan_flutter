import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/season_gallery.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/op_model.dart';
import 'package:mikan_flutter/providers/subscribed_season_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:mikan_flutter/widget/sliver_pinned_header.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliver_tools/sliver_tools.dart';

@FFRoute(
  name: "subscribed-season",
  routeName: "/subscribed-season",
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
        create: (_) => SubscribedSeasonModel(years, galleries),
        child: Builder(builder: (context) {
          final model =
              Provider.of<SubscribedSeasonModel>(context, listen: false);
          return Scaffold(
            body: Selector<SubscribedSeasonModel, List<SeasonGallery>>(
              selector: (_, model) => model.galleries,
              shouldRebuild: (pre, next) => pre.ne(next),
              builder: (context, galleries, __) {
                return SmartRefresher(
                  controller: model.refreshController,
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
                  onRefresh: model.refresh,
                  onLoading: model.loadMore,
                  child: _buildContentWrapper(
                    context,
                    theme,
                    galleries,
                  ),
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
        child: const Center(
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
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: edgeH16V8,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  gallery.title,
                  style: textStyle20B,
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
                        active: gallery.active,
                      ),
                    ),
                  );
                },
                color: theme.backgroundColor,
                minWidth: 32.0,
                padding: EdgeInsets.zero,
                shape: circleShape,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: const Icon(
                  FluentIcons.chevron_right_24_regular,
                  size: 16.0,
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
      builder: (
        context,
        ratio,
      ) {
        final ic = it.transform(ratio);
        return Row(
          children: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: ic,
              minWidth: 32.0,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: circleShape,
              child: const Icon(
                FluentIcons.chevron_left_24_regular,
                size: 16.0,
              ),
            ),
            sizedBoxW12,
            Text(
              "季度订阅",
              style: TextStyle(
                fontSize: 30.0 - (ratio * 6.0),
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),
          ],
        );
      },
    );
  }
}
