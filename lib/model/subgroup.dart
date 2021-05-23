import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';

part 'subgroup.g.dart';

@HiveType(typeId: MyHive.MIAKN_SUBGROUP)
class Subgroup extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String name;

  Subgroup({
    this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subgroup &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
