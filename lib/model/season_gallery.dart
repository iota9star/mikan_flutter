import 'package:mikan_flutter/model/bangumi.dart';

class SeasonGallery {
  late final String year;
  late final String season;
  late final String title;
  late final bool isCurrentSeason;
  late final List<Bangumi> bangumis;

  SeasonGallery({
    required this.year,
    required this.season,
    required this.title,
    this.isCurrentSeason = false,
    required this.bangumis,
  });

  SeasonGallery.empty();

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
