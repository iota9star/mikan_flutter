import 'package:mikan/core/models/bangumi_row.dart';
import 'package:mikan/core/models/season.dart' as model;

/// Immutable container for a season and its bangumi rows.
///
/// Used as the cached value type for [seasonProvider].
class SeasonData {
  const SeasonData({required this.season, required this.bangumiRows});

  final model.Season season;
  final List<BangumiRow> bangumiRows;
}
