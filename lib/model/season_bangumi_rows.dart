import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/season.dart';

class SeasonBangumis{
  Season season;
  List<BangumiRow> bangumiRows;

  SeasonBangumis({this.season, this.bangumiRows});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonBangumis &&
          runtimeType == other.runtimeType &&
          season == other.season;

  @override
  int get hashCode => season.hashCode;
}
