import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache_riverpod/kache_riverpod.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
import 'package:mikan/core/models/cached_list.dart';
import 'package:mikan/core/models/season_gallery.dart';
import 'package:mikan/core/models/subgroup.dart';

/// Persisted SWR cache for subgroup galleries.
final _subgroupGalleriesKacheProvider = kacheProvider.autoDispose.family<CachedSeasonGalleryList, Subgroup>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (ref, subgroup) {
    final id = subgroup.id;
    return KacheQuery<CachedSeasonGalleryList>.persisted(
      key: KacheKey('mikan', ['subgroup-galleries', id ?? subgroup.name]),
      binding: KacheInit.seasonGalleryListBinding,
      fetch: (_) async => CachedSeasonGalleryList(id == null ? const [] : await MikanApi.subgroup(id)),
      policy: KachePolicy.staleWhileRevalidate(),
    );
  },
);

/// Public provider that exposes [KacheSnapshot<List<SeasonGallery>>] to the UI,
/// mapped from the underlying CachedList snapshot.
final subgroupGalleriesProvider = Provider.autoDispose.family<KacheSnapshot<List<SeasonGallery>>, Subgroup>((
  ref,
  subgroup,
) {
  final snapshot = ref.watch(_subgroupGalleriesKacheProvider(subgroup));
  return snapshot.mapData((cached) => cached.items);
});

/// Forces a network refresh of the subgroup galleries cache.
Future<void> refreshSubgroupGalleries(WidgetRef ref, Subgroup subgroup) {
  return ref.read(_subgroupGalleriesKacheProvider(subgroup).notifier).refresh();
}
