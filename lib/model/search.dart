import 'bangumi.dart';
import 'record_item.dart';
import 'subgroup.dart';

class SearchResult {
  SearchResult({
    required this.bangumis,
    required this.subgroups,
    required this.records,
  });

  final List<Bangumi> bangumis;
  final List<Subgroup> subgroups;
  final List<RecordItem> records;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResult &&
          runtimeType == other.runtimeType &&
          bangumis == other.bangumis &&
          subgroups == other.subgroups &&
          records == other.records;

  @override
  int get hashCode => bangumis.hashCode ^ subgroups.hashCode ^ records.hashCode;
}
