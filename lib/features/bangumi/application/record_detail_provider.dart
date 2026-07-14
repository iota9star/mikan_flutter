import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache_riverpod/kache_riverpod.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
import 'package:mikan/core/models/record_details.dart';
import 'package:mikan/core/models/record_item.dart';

/// Persisted SWR cache for bangumi record details.
///
/// The cache key is derived from [RecordItem.url] (or [RecordItem.id] when the
/// url is empty). When the url is empty the record detail is derived locally
/// from the [RecordItem] fields and a fetcher is still provided so that an
/// explicit refresh can attempt a network load.
final _recordDetailKacheProvider = kacheProvider.autoDispose.family<RecordDetail, RecordItem>(
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
      policy: KachePolicy.staleWhileRevalidate(retainDataOnError: true),
    );
  },
);

/// Public provider that exposes [AsyncValue<RecordDetail>] to the UI, bridged
/// from the underlying [KacheSnapshot].
final recordDetailProvider =
    Provider.autoDispose.family<AsyncValue<RecordDetail>, RecordItem>((ref, record) {
  final snapshot = ref.watch(_recordDetailKacheProvider(record));
  return snapshotToAsync(snapshot, previous: null);
});

/// Forces a network refresh of the record detail cache and returns the
/// resulting [AsyncValue]. Use this from pull-to-refresh / retry handlers.
Future<AsyncValue<RecordDetail>> refreshRecordDetail(WidgetRef ref, RecordItem record) async {
  final snapshot = await ref.read(_recordDetailKacheProvider(record).notifier).refresh();
  return snapshotToAsync(snapshot, previous: null);
}

/// Invalidates the record detail cache entry so the next watch re-fetches.
void invalidateRecordDetail(WidgetRef ref, RecordItem record) {
  ref.invalidate(_recordDetailKacheProvider(record));
}
