import 'bangumi_row.dart';
import 'season.dart';

class SeasonBangumis {
  SeasonBangumis({
    required this.season,
    required this.bangumiRows,
  });

  final Season season;
  final List<BangumiRow> bangumiRows;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonBangumis &&
          runtimeType == other.runtimeType &&
          season == other.season;

  @override
  int get hashCode => season.hashCode;
}
