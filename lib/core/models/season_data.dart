import 'package:hive_ce/hive.dart';

import 'package:mikan/core/models/bangumi_row.dart';
import 'package:mikan/core/models/season.dart' as model;

part 'season_data.g.dart';

/// Immutable container for a season and its bangumi rows.
///
/// Used as the cached value type for [seasonProvider].
@HiveType(typeId: 102)
class SeasonData {
  SeasonData({required this.season, required this.bangumiRows});

  @HiveField(0)
  final model.Season season;

  @HiveField(1)
  final List<BangumiRow> bangumiRows;
}
