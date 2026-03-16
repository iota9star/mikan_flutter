import 'package:hive_ce/hive.dart';

import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/models/announcement.dart';
import 'package:mikan/core/models/bangumi_row.dart';
import 'package:mikan/core/models/carousel.dart';
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/models/user.dart';
import 'package:mikan/core/models/year_season.dart';

part 'index.g.dart';

@HiveType(typeId: MyHive.mikanIndex)
class Index extends HiveObject {
  Index({
    required this.years,
    required this.bangumiRows,
    required this.rss,
    required this.carousels,
    this.user,
    this.announcements,
  });

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

  @HiveField(5)
  final List<Announcement>? announcements;

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
  int get hashCode => years.hashCode ^ bangumiRows.hashCode ^ rss.hashCode ^ carousels.hashCode ^ user.hashCode;
}
