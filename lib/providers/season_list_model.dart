import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/season_bangumi_rows.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SeasonListModel extends CancelableBaseModel {
  bool _loading = false;

  bool get loading => _loading;

  List<Season> _seasons = [];

  List<Season> get seasons => _seasons;

  int _loadIndex = 0;

  SeasonListModel(this._years) {
    _seasons =
        _years.map((e) => e.seasons).expand((element) => element).toList();
    Future.delayed(const Duration(milliseconds: 250), () {
      _refreshController.requestRefresh();
    });
  }

  final List<YearSeason> _years;
  List<SeasonBangumis> _seasonBangumis = [];

  List<SeasonBangumis> get seasonBangumis => _seasonBangumis;

  final RefreshController _refreshController = RefreshController();

  RefreshController get refreshController => _refreshController;

  _loadSeasonBangumis() async {
    if (_loadIndex >= _seasons.length) {
      return _refreshController.loadNoData();
    }
    _loading = true;
    final Season season = _seasons[_loadIndex];
    final Resp resp = await (this + Repo.season(season.year, season.season));
    _loading = false;
    if (resp.success) {
      final SeasonBangumis seasonBangumis = SeasonBangumis(
        season: season,
        bangumiRows: resp.data ?? [],
      );
      if (_loadIndex == 0) {
        _seasonBangumis = [seasonBangumis];
      } else {
        _seasonBangumis = [..._seasonBangumis, seasonBangumis];
      }
      _loadIndex++;
      _refreshController.completed();
      notifyListeners();
    } else {
      _refreshController.failed();
      "获取${season.title}失败：${resp.msg}".toast();
    }
  }

  refresh() async {
    if (_loading) return "加载中，请等待加载完成";
    _loadIndex = 0;
    await _loadSeasonBangumis();
  }

  loadMore() async {
    if (_loading) return "加载中，请等待加载完成";
    await _loadSeasonBangumis();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
