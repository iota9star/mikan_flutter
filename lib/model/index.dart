import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/model/year_season.dart';

part 'index.g.dart';

@HiveType(typeId: MyHive.MIAKN_INDEX)
class Index extends HiveObject {
  @HiveField(0)
  final List<YearSeason> years;

  @HiveField(1)
  final List<BangumiRow> bangumiRows;

  @HiveField(2)
  final Map<String, List<RecordItem>> rss;

  @HiveField(3)
  final List<Carousel> carousels;

  @HiveField(4)
  final User? user;

  Index({
    required this.years,
    required this.bangumiRows,
    required this.rss,
    required this.carousels,
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
