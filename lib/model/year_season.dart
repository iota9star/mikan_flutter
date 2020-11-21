import 'package:mikan_flutter/model/season.dart';

class YearSeason {
  String year;
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
