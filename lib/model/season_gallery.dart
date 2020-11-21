import 'package:mikan_flutter/model/bangumi.dart';

class SeasonGallery {
  String date;
  String season;
  bool isCurrentSeason;
  List<Bangumi> bangumis;

  SeasonGallery({
    this.date,
    this.season,
    this.isCurrentSeason,
    this.bangumis,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonGallery &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          season == other.season &&
          isCurrentSeason == other.isCurrentSeason &&
          bangumis == other.bangumis;

  @override
  int get hashCode =>
      date.hashCode ^
      season.hashCode ^
      isCurrentSeason.hashCode ^
      bangumis.hashCode;
}
