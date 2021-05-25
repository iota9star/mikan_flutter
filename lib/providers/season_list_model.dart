import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/season_bangumi_rows.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SeasonListModel extends CancelableBaseModel {
  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (this._hasScrolled != value) {
      this._hasScrolled = value;
      notifyListeners();
    }
  }

  bool _loading = false;

  bool get loading => _loading;

  List<Season> _seasons = [];

  List<Season> get seasons => _seasons;

  int _loadIndex = 0;

  SeasonListModel(this._years) {
    this._seasons =
        this._years.map((e) => e.seasons).expand((element) => element).toList();
    Future.delayed(Duration(milliseconds: 250), () {
      this._refreshController.requestRefresh();
    });
  }

  final List<YearSeason> _years;
  List<SeasonBangumis> _seasonBangumis = [];

  List<SeasonBangumis> get seasonBangumis => _seasonBangumis;

  final RefreshController _refreshController = RefreshController();

  RefreshController get refreshController => _refreshController;

  _loadSeasonBangumis() async {
    if (this._loadIndex >= this._seasons.length) {
      return _refreshController.loadNoData();
    }
    this._loading = true;
    final Season season = this._seasons[this._loadIndex];
    final Resp resp = await (this + Repo.season(season.year, season.season));
    this._loading = false;
    if (resp.success) {
      final SeasonBangumis seasonBangumis = SeasonBangumis(
        season: season,
        bangumiRows: resp.data ?? [],
      );
      if (this._loadIndex == 0) {
        this._seasonBangumis = [seasonBangumis];
      } else {
        this._seasonBangumis = [...this._seasonBangumis, seasonBangumis];
      }
      this._loadIndex++;
      this._refreshController.completed();
      notifyListeners();
    } else {
      this._refreshController.failed();
      "获取${season.title}失败：${resp.msg}".toast();
    }
  }

  refresh() async {
    if (this._loading) return "加载中，请等待加载完成";
    this._loadIndex = 0;
    await _loadSeasonBangumis();
  }

  loadMore() async {
    if (this._loading) return "加载中，请等待加载完成";
    await _loadSeasonBangumis();
  }
}
