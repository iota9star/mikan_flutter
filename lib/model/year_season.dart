import 'package:mikan_flutter/model/season.dart';

class YearSeason {
  String year;
  List<Season> seasons;

  YearSeason({
    this.year,
    this.seasons,
  });

  @override
  String toString() {
    return 'YearSeason{year: $year, seasons: $seasons}';
  }
}
