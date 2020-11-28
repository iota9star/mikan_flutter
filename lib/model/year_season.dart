import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/model/season.dart';

part 'year_season.g.dart';

@HiveType(typeId: MyHive.MIAKN_YEARSEASON)
class YearSeason extends HiveObject {
  @HiveField(0)
  String year;
  @HiveField(1)
  List<Season> seasons;

  YearSeason({
    this.year,
    this.seasons,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearSeason &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          seasons == other.seasons;

  @override
  int get hashCode => year.hashCode ^ seasons.hashCode;
}
