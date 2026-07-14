import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache_riverpod/kache_riverpod.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
import 'package:mikan/core/models/season_gallery.dart';
import 'package:mikan/core/models/subgroup.dart';

/// Persisted SWR cache for subgroup galleries.
///
/// The cache key is derived from [Subgroup.id]. When the id is null an empty
/// list is returned without touching the cache.
final _subgroupGalleriesKacheProvider =
    kacheProvider.autoDispose.family<List<SeasonGallery>, Subgroup>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (ref, subgroup) {
    final id = subgroup.id;
    return KacheQuery<List<SeasonGallery>>.persisted(
      key: KacheKey('mikan', ['subgroup-galleries', id ?? subgroup.name]),
      binding: KacheInit.seasonGalleryListBinding,
      fetch: (_) async {
        if (id == null) {
          return [];
        }
        return MikanApi.subgroup(id);
      },
      policy: KachePolicy.staleWhileRevalidate(retainDataOnError: true),
    );
  },
);

/// Public provider that exposes [AsyncValue<List<SeasonGallery>>] to the UI,
/// bridged from the underlying [KacheSnapshot].
final subgroupGalleriesProvider =
    Provider.autoDispose.family<AsyncValue<List<SeasonGallery>>, Subgroup>((ref, subgroup) {
  final snapshot = ref.watch(_subgroupGalleriesKacheProvider(subgroup));
  return snapshotToAsync(snapshot, previous: null);
});

/// Forces a network refresh of the subgroup galleries cache and returns the
/// resulting [AsyncValue]. Use this from pull-to-refresh handlers.
Future<AsyncValue<List<SeasonGallery>>> refreshSubgroupGalleries(WidgetRef ref, Subgroup subgroup) async {
  final snapshot = await ref.read(_subgroupGalleriesKacheProvider(subgroup).notifier).refresh();
  return snapshotToAsync(snapshot, previous: null);
}
