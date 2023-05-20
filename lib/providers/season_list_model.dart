import 'package:easy_refresh/easy_refresh.dart';

import '../internal/extension.dart';
import '../internal/repo.dart';
import '../model/season.dart';
import '../model/season_bangumi_rows.dart';
import '../model/year_season.dart';
import 'base_model.dart';

class SeasonListModel extends BaseModel {
  SeasonListModel(this._years) {
    _seasons =
        _years.map((e) => e.seasons).expand((element) => element).toList();
  }

  List<Season> _seasons = [];

  List<Season> get seasons => _seasons;

  int _loadIndex = 0;

  final List<YearSeason> _years;
  List<SeasonBangumis> _bangumis = [];

  List<SeasonBangumis> get bangumis => _bangumis;

  Future<IndicatorResult> _loadBangumis() async {
    if (_loadIndex >= _seasons.length) {
      return IndicatorResult.noMore;
    }
    final season = _seasons[_loadIndex];
    final resp = await Repo.season(season.year, season.season);
    if (resp.success) {
      final seasonBangumis = SeasonBangumis(
        season: season,
        bangumiRows: resp.data ?? [],
      );
      if (_loadIndex == 0) {
        _bangumis = [seasonBangumis];
      } else {
        _bangumis = [..._bangumis, seasonBangumis];
      }
      _loadIndex++;
      notifyListeners();
      return IndicatorResult.success;
    } else {
      '获取 ${season.title} 失败：${resp.msg}'.toast();
      return IndicatorResult.fail;
    }
  }

  Future<IndicatorResult> refresh() {
    _loadIndex = 0;
    return _loadBangumis();
  }

  Future<IndicatorResult> loadMore() {
    return _loadBangumis();
  }
}
