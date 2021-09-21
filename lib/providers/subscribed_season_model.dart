import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/season_gallery.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SubscribedSeasonModel extends CancelableBaseModel {
  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (_hasScrolled != value) {
      _hasScrolled = value;
      notifyListeners();
    }
  }

  bool _loading = false;

  bool get loading => _loading;

  late List<Season> _seasons;

  List<Season> get seasons => _seasons;

  int _loadIndex = 1;

  SubscribedSeasonModel(this._years, this._galleries) {
    _seasons =
        _years.map((e) => e.seasons).expand((element) => element).toList();
  }

  final List<YearSeason> _years;

  List<SeasonGallery> _galleries;

  List<SeasonGallery> get galleries => _galleries;

  final RefreshController _refreshController =
      RefreshController(initialLoadStatus: LoadStatus.canLoading);

  RefreshController get refreshController => _refreshController;

  _loadSeasonBangumis() async {
    if (_loadIndex >= _seasons.length) {
      return _refreshController.loadNoData();
    }
    _loading = true;
    final Season season = _seasons[_loadIndex];
    final Resp resp = await (this +
        Repo.mySubscribedSeasonBangumi(season.year, season.season));
    _loading = false;
    if (resp.success) {
      final SeasonGallery seasonGallery = SeasonGallery(
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
      _refreshController.completed();
      notifyListeners();
    } else {
      _refreshController.failed();
      "获取${season.title}订阅失败：${resp.msg}".toast();
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
