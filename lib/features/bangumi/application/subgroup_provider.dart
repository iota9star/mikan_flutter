import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache_riverpod/kache_riverpod.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
export 'package:mikan/core/cache/kache_providers.dart' show KacheSnapshotWhenExtension;
import 'package:mikan/core/models/season_gallery.dart';
import 'package:mikan/core/models/subgroup.dart';

/// Persisted SWR cache for subgroup galleries.
///
/// UI reads this directly:
/// ```dart
/// final snapshot = ref.watch(subgroupGalleriesProvider(subgroup));
/// snapshot.when(data: ..., loading: ..., error: ...);
/// ```
final subgroupGalleriesProvider =
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
      policy: KachePolicy.staleWhileRevalidate(),
    );
  },
);

/// Forces a network refresh of the subgroup galleries cache.
Future<void> refreshSubgroupGalleries(WidgetRef ref, Subgroup subgroup) {
  return ref.read(subgroupGalleriesProvider(subgroup).notifier).refresh();
}
