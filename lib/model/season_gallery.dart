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
}
