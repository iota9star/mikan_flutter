import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../mikan_api.dart';
import '../../../../../shared/internal/extension.dart';
import '../../../../../shared/internal/hive.dart';
import '../../../../../shared/models/search.dart';

part 'search_provider.g.dart';

@riverpod
class SearchKeywords extends _$SearchKeywords {
  @override
  String? build() => null;

  /// Sets the search keywords.
  void set(String? value) => state = value;
}

@riverpod
class SearchSubgroupId extends _$SearchSubgroupId {
  @override
  String? build() => null;

  /// Toggles the subgroup selection.
  void toggle(String value) {
    state = state == value ? null : value;
  }

  /// Clears the selected subgroup.
  void clear() => state = null;
}

@riverpod
Future<SearchResult> search(Ref ref) async {
  final keywords = ref.watch(searchKeywordsProvider);
  final subgroupId = ref.watch(searchSubgroupIdProvider);

  if (keywords.isNullOrBlank) {
    return SearchResult(bangumis: [], subgroups: [], records: []);
  }

  final result = await MikanApi.search(keywords!, subgroupid: subgroupId ?? '');

  if (result.records.isNotEmpty) {
    _saveNewKeywords(keywords);
  }

  return result;
}

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
