import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/model/year_season.dart';

class Index {
  List<YearSeason> years;
  List<BangumiRow> bangumiRows;
  List<RecordItem> rss;
  List<Carousel> carousels;
  User user;

  Index({
    this.years,
    this.bangumiRows,
    this.rss,
    this.carousels,
    this.user,
  });
}
