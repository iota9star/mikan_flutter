import 'package:hive_ce/hive.dart';

import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/models/season.dart';

part 'year_season.g.dart';

@HiveType(typeId: MyHive.mikanYearSeason)
class YearSeason extends HiveObject {
  @HiveField(0)
  late String year;
  @HiveField(1)
  late List<Season> seasons;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearSeason && runtimeType == other.runtimeType && year == other.year && seasons == other.seasons;

  @override
  int get hashCode => year.hashCode ^ seasons.hashCode;
}
