import 'package:mikan_flutter/model/bangumi.dart';

class SeasonGallery {
  String year;
  String season;
  String title;
  bool isCurrentSeason;
  List<Bangumi> bangumis;

  SeasonGallery({
    this.year,
    this.season,
    this.title,
    this.isCurrentSeason,
    this.bangumis,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonGallery &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          season == other.season &&
          title == other.title &&
          isCurrentSeason == other.isCurrentSeason &&
          bangumis == other.bangumis;

  @override
  int get hashCode =>
      year.hashCode ^
      season.hashCode ^
      title.hashCode ^
      isCurrentSeason.hashCode ^
      bangumis.hashCode;
}
