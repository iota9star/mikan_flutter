import 'package:easy_refresh/easy_refresh.dart';

import '../internal/extension.dart';
import '../internal/repo.dart';
import '../model/season.dart';
import '../model/season_gallery.dart';
import '../model/year_season.dart';
import 'base_model.dart';

class SubscribedSeasonModel extends BaseModel {
  SubscribedSeasonModel(this._years, this._galleries) {
    _seasons =
        _years.map((e) => e.seasons).expand((element) => element).toList();
  }

  late List<Season> _seasons;

  List<Season> get seasons => _seasons;

  int _loadIndex = 1;

  final List<YearSeason> _years;

  List<SeasonGallery> _galleries;

  List<SeasonGallery> get galleries => _galleries;

  Future<IndicatorResult> _loadBangumis() async {
    if (_loadIndex >= _seasons.length) {
      return IndicatorResult.noMore;
    }
    final season = _seasons[_loadIndex];
    final resp =
        await Repo.mySubscribedSeasonBangumi(season.year, season.season);
    if (resp.success) {
      final seasonGallery = SeasonGallery(
        year: season.year,
        season: season.season,
        title: season.title,
        active: season.active,
        bangumis: resp.data ?? [],
      );
      if (_loadIndex == 0) {
        _galleries = [seasonGallery];
      } else {
        _galleries = [..._galleries, seasonGallery];
      }
      _loadIndex++;
      notifyListeners();
      return IndicatorResult.success;
    } else {
      '获取 ${season.title} 订阅失败 ${resp.msg ?? ''}'.toast();
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
