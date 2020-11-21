import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/model/year_season.dart';

class Index {
  List<YearSeason> years;
  List<BangumiRow> bangumiRows;
  Map<String, List<RecordItem>> rss;
  List<Carousel> carousels;
  User user;

  Index({
    this.years,
    this.bangumiRows,
    this.rss,
    this.carousels,
    this.user,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Index &&
          runtimeType == other.runtimeType &&
          years == other.years &&
          bangumiRows == other.bangumiRows &&
          rss == other.rss &&
          carousels == other.carousels &&
          user == other.user;

  @override
  int get hashCode =>
      years.hashCode ^
      bangumiRows.hashCode ^
      rss.hashCode ^
      carousels.hashCode ^
      user.hashCode;
}
