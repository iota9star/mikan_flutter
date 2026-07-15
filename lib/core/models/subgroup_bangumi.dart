import 'package:hive_ce/hive.dart';

import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/models/subgroup.dart';

part 'subgroup_bangumi.g.dart';

@HiveType(typeId: 104)
class SubgroupBangumi {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String dataId;

  @HiveField(2)
  late List<Subgroup> subgroups;

  @HiveField(3)
  late bool subscribed;

  @HiveField(4)
  String? sublang;

  @HiveField(5)
  String? rss;

  @HiveField(6)
  late int state;

  @HiveField(7)
  late List<RecordItem> records;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubgroupBangumi &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          dataId == other.dataId &&
          subgroups == other.subgroups &&
          subscribed == other.subscribed &&
          sublang == other.sublang &&
          rss == other.rss &&
          state == other.state &&
          records == other.records;

  @override
  int get hashCode =>
      name.hashCode ^
      dataId.hashCode ^
      subgroups.hashCode ^
      subscribed.hashCode ^
      sublang.hashCode ^
      rss.hashCode ^
      state.hashCode ^
      records.hashCode;
}
