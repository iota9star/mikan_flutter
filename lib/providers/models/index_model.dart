import 'package:mikan_flutter/core/http.dart';
import 'package:mikan_flutter/core/repo.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/index.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IndexModel extends CancelableBaseModel {
  List<YearSeason> _years = [];
  List<Season> _seasons = [];
  List<BangumiRow> _bangumiRows = [];
  List<RecordItem> _rss = [];
  List<Carousel> _carousels = [];
  Season _selectedSeason;
  User _user;
  int scaleIndex = -1;
  int selectedTabIndex = 0;
  bool _seasonLoading = false;

  bool get seasonLoading => _seasonLoading;

  Season get selectedSeason => _selectedSeason;

  List<Season> get seasons => _seasons;

  get selectTabName => _bangumiRows[selectedTabIndex].name;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  RefreshController get refreshController => _refreshController;

  IndexModel() {
    loadIndex();
  }

  Future loadIndex() async {
    if (this._seasonLoading) return "加载中，请稍候...".toast();
    await (this + _loadIndex());
  }

  _loadIndex() async {
    this._seasonLoading = true;
    notifyListeners();
    final Resp resp = await Repo.index();
    this._seasonLoading = false;
    if (resp.success) {
      final Index index = resp.data;
      if (index == null) return;
      this._years = index.years;
      this._seasons = [];
      for (final YearSeason ys in this._years) {
        this._seasons.addAll(ys.seasons);
        for (final Season season in ys.seasons) {
          if (season.active) {
            this._selectedSeason = season;
          }
        }
      }
      if (this._selectedSeason == null && this._seasons.isNotEmpty) {
        this._selectedSeason = this._seasons[0];
      }
      this._bangumiRows = index.bangumiRows;
      this._rss = index.rss;
      this._carousels = index.carousels;
      this._user = index.user;
      "加载完成...".toast();
    } else {
      if (resp.msg.isNotBlank) {
        resp.msg.toast();
      } else {
        "加载失败...".toast();
      }
    }
    notifyListeners();
  }

  List<BangumiRow> get bangumiRows => _bangumiRows;

  List<RecordItem> get rss => _rss;

  List<Carousel> get carousels => _carousels;

  List<YearSeason> get years => _years;

  User get user => _user;

  prevSeason() async {
    await (this + this._loadSeason((currIndex) => currIndex - 1));
  }

  nextSeason() async {
    await (this + this._loadSeason((currIndex) => currIndex + 1));
  }

  _loadSeason(final LoadSeasonIndex loadSeasonIndex) async {
    if (this._seasonLoading) return "加载中，请稍候...".toast();
    final int index = this
        ._seasons
        .indexWhere((element) => element.title == this._selectedSeason.title);
    assert(index >= 0);
    final int nextIndex = loadSeasonIndex.call(index);
    if (nextIndex < 0) {
      return "已经到最新季度了...".toast();
    } else if (nextIndex == this._seasons.length) {
      return "已经到最老季度了...".toast();
    }
    this._selectedSeason = this._seasons[nextIndex];
    notifyListeners();
    this._seasonLoading = true;
    final Resp resp = await Repo.season(
      this._selectedSeason.year,
      this._selectedSeason.season,
    );
    this._seasonLoading = false;
    if (this.disposed) return;
    if (resp.success) {
      this._bangumiRows = resp.data;
      "加载完成...".toast();
    } else {
      if (resp.msg.isNotBlank) {
        resp.msg.toast();
      } else {
        "加载失败...".toast();
      }
    }
    notifyListeners();
  }
}

typedef LoadSeasonIndex = int Function(int currIndex);
