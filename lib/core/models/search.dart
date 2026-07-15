import 'package:hive_ce/hive.dart';

import 'package:mikan/core/models/bangumi.dart';
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/models/subgroup.dart';

part 'search.g.dart';

@HiveType(typeId: 105)
class SearchResult {
  SearchResult({required this.bangumis, required this.subgroups, required this.records});

  @HiveField(0)
  final List<Bangumi> bangumis;

  @HiveField(1)
  final List<Subgroup> subgroups;

  @HiveField(2)
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
