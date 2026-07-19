import 'package:flutter/foundation.dart';
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
          user == other.user &&
          // Structural comparisons so objects rebuilt from identical data
          // compare equal even when List/Map identities differ.
          listEquals(years, other.years) &&
          listEquals(bangumiRows, other.bangumiRows) &&
          listEquals(carousels, other.carousels) &&
          listEquals(announcements, other.announcements) &&
          _rssEquals(rss, other.rss);

  @override
  int get hashCode => Object.hash(
    user,
    Object.hashAll(years),
    Object.hashAll(bangumiRows),
    Object.hashAll(carousels),
    announcements == null ? null : Object.hashAll(announcements!),
    // Deep-hash the rss map values.
    Object.hashAll(rss.entries.expand((e) => [e.key, Object.hashAll(e.value)])),
  );

  /// Deep equality for the rss map whose values are lists of [RecordItem].
  static bool _rssEquals(Map<String, List<RecordItem>> a, Map<String, List<RecordItem>> b) {
    if (a.length != b.length) {
      return false;
    }
    for (final key in a.keys) {
      final av = a[key];
      final bv = b[key];
      if (bv == null || !listEquals(av, bv)) {
        return false;
      }
    }
    return true;
  }
}
