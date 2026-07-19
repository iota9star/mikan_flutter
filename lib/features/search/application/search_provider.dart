import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache_riverpod/kache_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
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

/// Named-record argument for the search family provider.
typedef SearchArgs = ({String keywords, String subgroupId});

/// Persisted SWR cache for search results, keyed by (keywords, subgroupId).
final _searchKacheProvider = kacheProvider.autoDispose.family<SearchResult, SearchArgs>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (ref, args) => KacheQuery<SearchResult>.persisted(
    key: KacheKey('mikan', ['search', args.keywords, args.subgroupId]),
    binding: KacheInit.searchResultBinding,
    fetch: (_) async {
      final result = await MikanApi.search(args.keywords, subgroupid: args.subgroupId);
      if (result.records.isNotEmpty || result.bangumis.isNotEmpty || result.subgroups.isNotEmpty) {
        _saveNewKeywords(args.keywords);
      }
      return result;
    },
    policy: KachePolicy.staleWhileRevalidate(),
  ),
);

/// An idle snapshot returned when there are no search keywords.
final _emptySearchSnapshot = KacheSnapshot<SearchResult>.idle();

/// Public provider that exposes [KacheSnapshot<SearchResult>] to the UI.
///
/// Returns an idle snapshot when keywords are empty.
final searchProvider = Provider.autoDispose<KacheSnapshot<SearchResult>>((ref) {
  final keywords = ref.watch(searchKeywordsProvider);
  final subgroupId = ref.watch(searchSubgroupIdProvider);

  if (keywords.isNullOrBlank) {
    return _emptySearchSnapshot;
  }

  final args = (keywords: keywords!, subgroupId: subgroupId ?? '');
  return ref.watch(_searchKacheProvider(args));
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
