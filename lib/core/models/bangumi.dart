import 'package:hive_ce/hive.dart';

import 'package:mikan/core/common/hive.dart';

part 'bangumi.g.dart';

@HiveType(typeId: MyHive.mikanBangumi)
class Bangumi extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String updateAt = '';

  @HiveField(2)
  int? num;

  @HiveField(3)
  late String name;

  @HiveField(4)
  late String cover;

  @HiveField(5)
  late bool subscribed = false;

  @HiveField(6)
  late bool grey = false;

  @HiveField(8)
  late String week = '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bangumi &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          updateAt == other.updateAt &&
          num == other.num &&
          name == other.name &&
          cover == other.cover &&
          subscribed == other.subscribed &&
          grey == other.grey &&
          week == other.week;

  @override
  int get hashCode =>
      id.hashCode ^
      updateAt.hashCode ^
      num.hashCode ^
      name.hashCode ^
      cover.hashCode ^
      subscribed.hashCode ^
      grey.hashCode ^
      week.hashCode;
}
