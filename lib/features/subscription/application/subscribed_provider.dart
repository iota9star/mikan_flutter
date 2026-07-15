import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache_riverpod/kache_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
export 'package:mikan/core/cache/kache_providers.dart' show KacheSnapshotWhenExtension;
import 'package:mikan/core/models/bangumi.dart';
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/models/season.dart';

part 'subscribed_provider.g.dart';

/// Persisted SWR cache for subscribed bangumi list of a specific season.
///
/// UI reads this directly:
/// ```dart
/// final snapshot = ref.watch(subscribedBangumisProvider(season));
/// snapshot.when(data: ..., loading: ..., error: ...);
/// ```
final subscribedBangumisProvider =
    kacheProvider.autoDispose.family<List<Bangumi>, Season>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (ref, season) => KacheQuery<List<Bangumi>>.persisted(
    key: KacheKey('mikan', ['subscribed-bangumis', season.year, season.season]),
    binding: KacheInit.bangumiListBinding,
    fetch: (_) => MikanApi.mySubscribedSeasonBangumi(season.year, season.season),
    policy: KachePolicy.staleWhileRevalidate(),
  ),
);

/// Persisted SWR cache for recent subscription records (day(2)).
///
/// UI reads this directly:
/// ```dart
/// final snapshot = ref.watch(recentRecordsProvider);
/// snapshot.when(data: ..., loading: ..., error: ...);
/// ```
final recentRecordsProvider = kacheProvider.autoDispose<List<RecordItem>>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (_) => KacheQuery<List<RecordItem>>.persisted(
    key: KacheKey('mikan', ['recent-records']),
    binding: KacheInit.recordListBinding,
    fetch: (_) => MikanApi.day(2),
    policy: KachePolicy.staleWhileRevalidate(),
  ),
);

@riverpod
Map<String, List<RecordItem>> rssRecords(Ref ref) {
  final snapshot = ref.watch(recentRecordsProvider);
  final records = snapshot.dataOrNull ?? const <RecordItem>[];

  return groupBy(
    records.where((it) => it.id?.isNotEmpty ?? false),
    (it) => it.id!,
  );
}
