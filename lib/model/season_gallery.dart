import 'bangumi.dart';

class SeasonGallery {
  SeasonGallery({
    required this.year,
    required this.season,
    required this.title,
    this.active = false,
    required this.bangumis,
  });

  SeasonGallery.empty();

  late String year = '';
  late String season = '';
  late String title = '';
  late bool active = false;
  late List<Bangumi> bangumis;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonGallery &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          season == other.season &&
          title == other.title &&
          active == other.active &&
          bangumis == other.bangumis;

  @override
  int get hashCode =>
      year.hashCode ^
      season.hashCode ^
      title.hashCode ^
      active.hashCode ^
      bangumis.hashCode;
}
