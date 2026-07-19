import 'package:hive_ce/hive.dart';

import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/models/subgroup.dart';

part 'subgroup_bangumi.g.dart';

@HiveType(typeId: 104)
class SubgroupBangumi {
  /// Hive requires a no-arg default constructor for deserialization; app code
  /// should prefer [SubgroupBangumi.create], whose required parameters make a
  /// missing field a compile-time error instead of a runtime
  /// [LateInitializationError].
  SubgroupBangumi();

  SubgroupBangumi.create({
    required this.name,
    required this.dataId,
    required this.subgroups,
    required this.subscribed,
    this.sublang,
    this.rss,
    required this.state,
    required this.records,
  });

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

  /// Returns a copy with the given fields replaced.
  SubgroupBangumi copyWith({
    String? name,
    String? dataId,
    List<Subgroup>? subgroups,
    bool? subscribed,
    String? sublang,
    String? rss,
    int? state,
    List<RecordItem>? records,
  }) {
    return SubgroupBangumi.create(
      name: name ?? this.name,
      dataId: dataId ?? this.dataId,
      subgroups: subgroups ?? this.subgroups,
      subscribed: subscribed ?? this.subscribed,
      sublang: sublang ?? this.sublang,
      rss: rss ?? this.rss,
      state: state ?? this.state,
      records: records ?? this.records,
    );
  }

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
