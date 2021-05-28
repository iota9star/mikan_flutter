import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';

part 'season.g.dart';

@HiveType(typeId: MyHive.MIAKN_SEASON)
class Season extends HiveObject {
  @HiveField(0)
  late String year = "";

  @HiveField(1)
  late String season = "";

  @HiveField(2)
  late String title = "";

  @HiveField(3)
  late bool active = false;

  Season({
    required this.year,
    required this.season,
    required this.title,
    required this.active,
  });

  Season.empty();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Season &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}
