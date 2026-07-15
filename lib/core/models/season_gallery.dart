import 'package:hive_ce/hive.dart';

import 'package:mikan/core/models/bangumi.dart';

part 'season_gallery.g.dart';

@HiveType(typeId: 101)
class SeasonGallery {
  SeasonGallery({
    required this.year,
    required this.season,
    required this.title,
    this.active = false,
    required this.bangumis,
  });

  SeasonGallery.empty();

  @HiveField(0)
  late String year = '';

  @HiveField(1)
  late String season = '';

  @HiveField(2)
  late String title = '';

  @HiveField(3)
  late bool active = false;

  @HiveField(4)
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
  int get hashCode => year.hashCode ^ season.hashCode ^ title.hashCode ^ active.hashCode ^ bangumis.hashCode;
}
