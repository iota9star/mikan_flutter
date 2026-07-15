import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache_riverpod/kache_riverpod.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
export 'package:mikan/core/cache/kache_providers.dart' show KacheSnapshotWhenExtension;
import 'package:mikan/core/models/record_details.dart';
import 'package:mikan/core/models/record_item.dart';

/// Persisted SWR cache for bangumi record details.
///
/// The cache key is derived from [RecordItem.url] (or [RecordItem.id] when the
/// url is empty).
///
/// UI reads this directly:
/// ```dart
/// final snapshot = ref.watch(recordDetailProvider(record));
/// snapshot.when(data: ..., loading: ..., error: ...);
/// ```
final recordDetailProvider = kacheProvider.autoDispose.family<RecordDetail, RecordItem>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (ref, record) {
    final keyPart = record.url.isNotEmpty ? record.url : (record.id ?? record.name);
    return KacheQuery<RecordDetail>.persisted(
      key: KacheKey('mikan', ['record-detail', keyPart]),
      binding: KacheInit.recordDetailBinding,
      fetch: (_) async {
        if (record.url.isEmpty) {
          return RecordDetail()
            ..name = record.name
            ..url = record.url
            ..title = record.title
            ..subgroups = record.groups
            ..id = record.id
            ..cover = record.cover
            ..tags = record.tags
            ..torrent = record.torrent
            ..magnet = record.magnet;
        }
        final episodeId = record.url.split('/').last;
        return MikanApi.details(episodeId);
      },
      policy: KachePolicy.staleWhileRevalidate(),
    );
  },
);

/// Forces a network refresh of the record detail cache.
Future<void> refreshRecordDetail(WidgetRef ref, RecordItem record) {
  return ref.read(recordDetailProvider(record).notifier).refresh();
}

/// Invalidates the record detail cache entry.
void invalidateRecordDetail(WidgetRef ref, RecordItem record) {
  ref.invalidate(recordDetailProvider(record));
}
