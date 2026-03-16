import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFAutoImport()
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:mikan/app/routing/mikan_routes.dart';
import 'package:mikan/res/assets.gen.dart';
import 'package:mikan/core/widgets/sliver_bangumi_list.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/core/common/extension.dart';
@FFAutoImport()
import 'package:mikan/core/models/season.dart';
@FFAutoImport()
import 'package:mikan/core/models/season_gallery.dart';
@FFAutoImport()
import 'package:mikan/core/models/year_season.dart';
import 'package:mikan/core/widgets/scalable_tap.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';
import 'package:mikan/features/subscription/application/subscribed_season_provider.dart';

@FFRoute(name: '/subscribed/season')
@immutable
class SubscribedSeasonPage extends ConsumerWidget {
  const SubscribedSeasonPage({super.key, required this.years, required this.galleries});

  final List<YearSeason> years;

  final List<SeasonGallery> galleries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    // Only rebuild when galleries change, not when loadIndex or other state changes
    final watchedGalleries = ref.watch(subscribedSeasonProvider(years, galleries).select((state) => state.galleries));
    return Scaffold(
      body: EasyRefresh(
        refreshOnStart: galleries.isEmpty,
        header: defaultHeader,
        footer: defaultFooter(context),
        onRefresh: () => ref.read(subscribedSeasonProvider(years, galleries).notifier).refresh(),
        onLoad: () => ref.read(subscribedSeasonProvider(years, galleries).notifier).loadMore(),
        child: _buildBody(context, ref, theme, watchedGalleries),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ThemeData theme, List<SeasonGallery> galleries) {
    return CustomScrollView(
      slivers: [
        const SliverPinnedAppBar(title: '季度订阅'),
        if (galleries.isNotEmpty)
          ...List.generate(galleries.length, (index) {
            final gallery = galleries[index];
            return MultiSliver(
              pushPinnedChildren: true,
              children: <Widget>[
                _buildSeasonSection(context, theme, gallery),
                if (gallery.bangumis.isNullOrEmpty)
                  _buildEmptySubscribedContainer(theme)
                else
                  ProviderScope(
                    overrides: [bangumisListProvider.overrideWithValue(gallery.bangumis)],
                    child: const SliverBangumiList(),
                  ),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildEmptySubscribedContainer(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: ScalableCard(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  Assets.mikan.image(width: 64.0),
                  const Gap(12),
                  Text('>_< 您还没有订阅当前季度番组，快去添加订阅吧', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonSection(BuildContext context, ThemeData theme, SeasonGallery gallery) {
    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsetsDirectional.only(start: 24.0, end: 12.0),
          height: 48.0,
          child: Row(
            children: [
              Expanded(child: Text(gallery.title, style: theme.textTheme.titleMedium)),
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
