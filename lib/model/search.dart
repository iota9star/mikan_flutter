import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/subgroup.dart';

class SearchResult {
  final List<Bangumi> bangumis;
  final List<Subgroup> subgroups;
  final List<RecordItem> records;

  SearchResult({
    required this.bangumis,
    required this.subgroups,
    required this.records,
  });

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
