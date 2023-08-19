import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../internal/extension.dart';
import '../../mikan_routes.dart';
@FFArgumentImport()
import '../../model/season.dart';
@FFArgumentImport()
import '../../model/season_gallery.dart';
@FFArgumentImport()
import '../../model/year_season.dart';
import '../../providers/op_model.dart';
import '../../providers/subscribed_season_model.dart';
import '../../res/assets.gen.dart';
import '../../topvars.dart';
import '../../widget/scalable_tap.dart';
import '../../widget/sliver_pinned_header.dart';
import '../fragments/sliver_bangumi_list.dart';

@FFRoute(name: '/subscribed/season')
@immutable
class SubscribedSeasonPage extends StatelessWidget {
  const SubscribedSeasonPage({
    super.key,
    required this.years,
    required this.galleries,
  });

  final List<YearSeason> years;

  final List<SeasonGallery> galleries;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => SubscribedSeasonModel(years, galleries),
        child: Builder(
          builder: (context) {
            final model =
                Provider.of<SubscribedSeasonModel>(context, listen: false);
            return Scaffold(
              body: Selector<SubscribedSeasonModel, List<SeasonGallery>>(
                selector: (_, model) => model.galleries,
                shouldRebuild: (pre, next) => pre.ne(next),
                builder: (context, galleries, __) {
                  return EasyRefresh(
                    header: defaultHeader,
                    footer: defaultFooter(context),
                    onRefresh: model.refresh,
                    onLoad: model.loadMore,
                    child: _buildBody(
                      context,
                      theme,
                      galleries,
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

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    List<SeasonGallery> galleries,
  ) {
    return CustomScrollView(
      slivers: [
        const SliverPinnedAppBar(title: '季度订阅'),
        if (galleries.isNotEmpty)
          ...List.generate(
            galleries.length,
            (index) {
              final gallery = galleries[index];
              return MultiSliver(
                pushPinnedChildren: true,
                children: <Widget>[
                  _buildSeasonSection(context, theme, gallery),
                  if (gallery.bangumis.isNullOrEmpty)
                    _buildEmptySubscribedContainer(theme)
                  else
                    SliverBangumiList(
                      flag: gallery.title,
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
  }

  Widget _buildEmptySubscribedContainer(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        margin: edgeH24B16,
        child: ScalableCard(
          onTap: () {},
          child: Padding(
            padding: edge24,
            child: Center(
              child: Column(
                children: [
                  Assets.mikan.image(width: 64.0),
                  sizedBoxH12,
                  Text(
                    '>_< 您还没有订阅当前季度番组，快去添加订阅吧',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonSection(
    BuildContext context,
    ThemeData theme,
    SeasonGallery gallery,
  ) {
    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: edgeS24E12,
          height: 48.0,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  gallery.title,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.east_rounded),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
