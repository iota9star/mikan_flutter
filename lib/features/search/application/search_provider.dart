import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/kache.dart';
import 'package:kache_riverpod/kache_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
export 'package:mikan/core/cache/kache_providers.dart' show KacheSnapshotWhenExtension;
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/models/search.dart';

part 'search_provider.g.dart';

@riverpod
class SearchKeywords extends _$SearchKeywords {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

@riverpod
class SearchSubgroupId extends _$SearchSubgroupId {
  @override
  String? build() => null;

  void toggle(String value) {
    state = state == value ? null : value;
  }

  void clear() => state = null;
}

/// Persisted SWR cache for search results, keyed by `keywords|subgroupId`.
final _searchKacheProvider = kacheProvider.autoDispose.family<SearchResult, String>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (ref, cacheKey) {
    final sep = cacheKey.indexOf('|');
    final keywords = sep >= 0 ? cacheKey.substring(0, sep) : cacheKey;
    final subgroupId = sep >= 0 ? cacheKey.substring(sep + 1) : '';
    return KacheQuery<SearchResult>.persisted(
      key: KacheKey('mikan', ['search', cacheKey]),
      binding: KacheInit.searchResultBinding,
      fetch: (_) async {
        final result = await MikanApi.search(keywords, subgroupid: subgroupId);
        if (result.records.isNotEmpty || result.bangumis.isNotEmpty || result.subgroups.isNotEmpty) {
          _saveNewKeywords(keywords);
        }
        return result;
      },
      policy: KachePolicy.staleWhileRevalidate(),
    );
  },
);

/// An idle snapshot returned when there are no search keywords.
final _emptySearchSnapshot = KacheSnapshot<SearchResult>.idle();

/// Public provider that exposes [KacheSnapshot<SearchResult>] to the UI.
///
/// Returns an idle snapshot when keywords are empty. Otherwise watches the
/// underlying kache family provider.
final searchProvider =
    Provider.autoDispose<KacheSnapshot<SearchResult>>((ref) {
  final keywords = ref.watch(searchKeywordsProvider);
  final subgroupId = ref.watch(searchSubgroupIdProvider);

  if (keywords.isNullOrBlank) {
    return _emptySearchSnapshot;
  }

  final cacheKey = '$keywords|${subgroupId ?? ''}';
  return ref.watch(_searchKacheProvider(cacheKey));
});

void _saveNewKeywords(String keywords) {
  final List<String> history = MyHive.db.get(HiveDBKey.mikanSearch, defaultValue: <String>[]);
  if (history.contains(keywords)) {
    return;
  }
  history.insert(0, keywords);
  if (history.length > 8) {
    history.remove(history.last);
  }
  MyHive.db.put(HiveDBKey.mikanSearch, history);
}
