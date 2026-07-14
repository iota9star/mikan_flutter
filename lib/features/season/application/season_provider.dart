import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache_riverpod/kache_riverpod.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
import 'package:mikan/core/models/season.dart' as model;
import 'package:mikan/core/models/season_data.dart';

/// Persisted SWR cache for season bangumi rows.
///
/// The family argument ([model.Season]) is incorporated into the [KacheKey]
/// so each season is cached independently. Reconnection triggers automatic
/// revalidation.
final _seasonKacheProvider = kacheProvider.autoDispose.family<SeasonData, model.Season>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (ref, season) => KacheQuery<SeasonData>.persisted(
    key: KacheKey('mikan', ['season', season.year, season.season]),
    binding: KacheInit.seasonDataBinding,
    fetch: (_) async {
      final bangumiRows = await MikanApi.season(season.year, season.season);
      return SeasonData(season: season, bangumiRows: bangumiRows);
    },
    policy: KachePolicy.staleWhileRevalidate(retainDataOnError: true),
  ),
);

/// Public provider that exposes [AsyncValue<SeasonData>] to the UI, bridged
/// from the underlying [KacheSnapshot].
final seasonProvider = Provider.autoDispose.family<AsyncValue<SeasonData>, model.Season>((ref, season) {
  final snapshot = ref.watch(_seasonKacheProvider(season));
  return snapshotToAsync(snapshot, previous: null);
});

/// Forces a network refresh of the season cache and returns the resulting
/// [AsyncValue]. Use this from pull-to-refresh handlers.
Future<AsyncValue<SeasonData>> refreshSeason(WidgetRef ref, model.Season season) async {
  final snapshot = await ref.read(_seasonKacheProvider(season).notifier).refresh();
  return snapshotToAsync(snapshot, previous: null);
}

/// Invalidates all cached season entries so the next watch re-fetches from
/// network. Call this after subscription state changes.
void invalidateAllSeasons(WidgetRef ref) {
  ref.invalidate(_seasonKacheProvider);
}
