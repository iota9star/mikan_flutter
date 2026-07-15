import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache_riverpod/kache_riverpod.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
export 'package:mikan/core/cache/kache_providers.dart' show KacheSnapshotWhenExtension;
import 'package:mikan/core/models/season.dart' as model;
import 'package:mikan/core/models/season_data.dart';

/// Persisted SWR cache for season bangumi rows.
///
/// The family argument ([model.Season]) is incorporated into the [KacheKey]
/// so each season is cached independently. Reconnection triggers automatic
/// revalidation.
///
/// UI reads this directly:
/// ```dart
/// final snapshot = ref.watch(seasonProvider(season));
/// snapshot.when(data: ..., loading: ..., error: ...);
/// ```
final seasonProvider = kacheProvider.autoDispose.family<SeasonData, model.Season>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (ref, season) => KacheQuery<SeasonData>.persisted(
    key: KacheKey('mikan', ['season', season.year, season.season]),
    binding: KacheInit.seasonDataBinding,
    fetch: (_) async {
      final bangumiRows = await MikanApi.season(season.year, season.season);
      return SeasonData(season: season, bangumiRows: bangumiRows);
    },
    policy: KachePolicy.staleWhileRevalidate(),
  ),
);

/// Forces a network refresh of the season cache. Use from pull-to-refresh.
Future<void> refreshSeason(WidgetRef ref, model.Season season) {
  return ref.read(seasonProvider(season).notifier).refresh();
}

/// Invalidates all cached season entries so the next watch re-fetches.
void invalidateAllSeasons(WidgetRef ref) {
  ref.invalidate(seasonProvider);
}
