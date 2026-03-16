import 'package:easy_refresh/easy_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFAutoImport()
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'package:mikan/core/models/season_gallery.dart';
@FFAutoImport()
import 'package:mikan/core/models/subgroup.dart';
import 'package:mikan/core/widgets/sliver_bangumi_list.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/features/bangumi/application/subgroup_provider.dart';

@FFRoute(name: '/subgroup')
@immutable
class SubgroupPage extends ConsumerWidget {
  const SubgroupPage({super.key, required this.subgroup});

  final Subgroup subgroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final galleriesAsync = ref.watch(subgroupGalleriesProvider(subgroup));

    return Scaffold(
      body: galleriesAsync.when(
        data: (galleries) {
          return EasyRefresh(
            header: defaultHeader,
            onRefresh: () => ref.refresh(subgroupGalleriesProvider(subgroup).future),
            child: CustomScrollView(
              slivers: [
                SliverPinnedAppBar(title: subgroup.name),
                ...List.generate(galleries.length, (index) {
                  final gallery = galleries[index];
                  return _buildList(context, theme, gallery, ref);
                }),
              ],
            ),
          );
        },
        loading: () => const Center(child: ExpressiveLoadingIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
      ),
    );
  }

  Widget _buildList(BuildContext context, ThemeData theme, SeasonGallery gallery, WidgetRef ref) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: <Widget>[
        _buildYearSeasonSection(theme, gallery.title),
        ProviderScope(
          overrides: [bangumisListProvider.overrideWithValue(gallery.bangumis)],
          child: const SliverBangumiList(),
        ),
      ],
    );
  }

  Widget _buildYearSeasonSection(ThemeData theme, String section) {
    return SliverPinnedHeader(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          height: 48.0,
          color: theme.colorScheme.surface,
          alignment: AlignmentDirectional.centerStart,
          child: Text(section, style: theme.textTheme.titleMedium),
        ),
      ),
    );
  }
}
