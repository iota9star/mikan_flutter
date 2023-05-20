import 'package:hive/hive.dart';

import '../internal/hive.dart';

part 'subgroup.g.dart';

@HiveType(typeId: MyHive.mikanSubgroup)
class Subgroup extends HiveObject {
  Subgroup({
    this.id,
    required this.name,
  });

  @HiveField(0)
  String? id;

  @HiveField(1)
  String name;

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
