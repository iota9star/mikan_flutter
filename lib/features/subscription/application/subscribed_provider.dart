import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/kache.dart';
import 'package:kache_riverpod/kache_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
import 'package:mikan/core/models/bangumi.dart';
import 'package:mikan/core/models/cached_list.dart';
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/models/season.dart';

part 'subscribed_provider.g.dart';

/// Persisted SWR cache for subscribed bangumi list of a specific season.
final _subscribedBangumisKacheProvider =
    kacheProvider.autoDispose.family<CachedBangumiList, Season>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (ref, season) => KacheQuery<CachedBangumiList>.persisted(
    key: KacheKey('mikan', ['subscribed-bangumis', season.year, season.season]),
    binding: KacheInit.bangumiListBinding,
    fetch: (_) async =>
        CachedBangumiList(await MikanApi.mySubscribedSeasonBangumi(season.year, season.season)),
    policy: KachePolicy.staleWhileRevalidate(),
  ),
);

/// Public provider mapped to List<Bangumi>.
final subscribedBangumisProvider =
    Provider.autoDispose.family<KacheSnapshot<List<Bangumi>>, Season>((ref, season) {
  final snapshot = ref.watch(_subscribedBangumisKacheProvider(season));
  return snapshot.mapData((cached) => cached.items);
});

/// Persisted SWR cache for recent subscription records (day(2)).
final _recentRecordsKacheProvider = kacheProvider.autoDispose<CachedRecordList>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (_) => KacheQuery<CachedRecordList>.persisted(
    key: KacheKey('mikan', ['recent-records']),
    binding: KacheInit.recordListBinding,
    fetch: (_) async => CachedRecordList(await MikanApi.day(2)),
    policy: KachePolicy.staleWhileRevalidate(),
  ),
);

/// Public provider mapped to List<RecordItem>.
final recentRecordsProvider =
    Provider.autoDispose<KacheSnapshot<List<RecordItem>>>((ref) {
  final snapshot = ref.watch(_recentRecordsKacheProvider);
  return snapshot.mapData((cached) => cached.items);
});

@riverpod
Map<String, List<RecordItem>> rssRecords(Ref ref) {
  final snapshot = ref.watch(recentRecordsProvider);
  final records = snapshot.dataOrNull ?? const <RecordItem>[];

  return groupBy(
    records.where((it) => it.id?.isNotEmpty ?? false),
    (it) => it.id!,
  );
}

/// Forces a network refresh of recent records.
Future<void> refreshRecentRecords(WidgetRef ref) {
  return ref.read(_recentRecordsKacheProvider.notifier).refresh();
}

/// Forces a network refresh of subscribed bangumis for a season.
Future<void> refreshSubscribedBangumis(WidgetRef ref, Season season) {
  return ref.read(_subscribedBangumisKacheProvider(season).notifier).refresh();
}
