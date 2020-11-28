import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';

part 'season.g.dart';

@HiveType(typeId: MyHive.MIAKN_SEASON)
class Season extends HiveObject {
  @HiveField(0)
  String year;

  @HiveField(1)
  String season;

  @HiveField(2)
  String title;

  @HiveField(3)
  bool active;

  Season({
    this.year,
    this.season,
    this.title,
    this.active,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Season &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}
