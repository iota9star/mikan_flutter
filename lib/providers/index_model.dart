import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/index.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:mikan_flutter/providers/subscribed_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IndexModel extends CancelableBaseModel {
  List<YearSeason> _years = [];
  List<BangumiRow> _bangumiRows = [];
  List<RecordItem> _ovas = [];
  List<Carousel> _carousels = [];
  Season? _selectedSeason;
  User? _user;
  BangumiRow? _selectedBangumiRow;

  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (this._hasScrolled != value) {
      this._hasScrolled = value;
      notifyListeners();
    }
  }

  BangumiRow? get selectedBangumiRow => _selectedBangumiRow;

  set selectedBangumiRow(BangumiRow? value) {
    _selectedBangumiRow = value;
    notifyListeners();
  }

  bool _seasonLoading = false;

  bool get seasonLoading => _seasonLoading;

  Season? get selectedSeason => _selectedSeason;

  List<RecordItem> get ovas => _ovas;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  RefreshController get refreshController => _refreshController;

  bool _ovaLoading = false;

  bool get ovaLoading => _ovaLoading;

  SubscribedModel _subscribedModel;

  IndexModel(this._subscribedModel) {
    this._ovas = (MyHive.db
            .get(HiveDBKey.MIKAN_OVA, defaultValue: <RecordItem>[]) as List)
        .cast<RecordItem>();
    final Index? index = MyHive.db.get(HiveDBKey.MIKAN_INDEX);
    this._bindIndexData(index);
  }

  refresh() async {
    await _loadIndex();
    await _loadOVA();
    _refreshController.refreshCompleted();
  }

  _loadOVA() async {
    this._ovaLoading = true;
    notifyListeners();
    final Resp resp = await (this + Repo.ova());
    this._ovaLoading = false;
    if (resp.success) {
      this._ovas = resp.data;
      MyHive.db.put(HiveDBKey.MIKAN_OVA, this._ovas);
    } else {
      "获取OVA失败：${resp.msg}".toast();
    }
    notifyListeners();
  }

  _loadIndex() async {
    this._seasonLoading = true;
    notifyListeners();
    final Resp resp = await (this + Repo.index());
    this._seasonLoading = false;
    if (resp.success) {
      final Index index = resp.data;
      MyHive.db.put(HiveDBKey.MIKAN_INDEX, index);
      _bindIndexData(index);
      "加载完成".toast();
    } else {
      "获取首页数据失败：${resp.msg}".toast();
    }
    notifyListeners();
  }

  void _bindIndexData(final Index? index) {
    if (index == null) return;
    this._years = index.years;
    this._subscribedModel.years = this._years;
    this._selectedSeason = this._years.getOrNull(0)?.seasons.getOrNull(0);
    this._bangumiRows = index.bangumiRows;
    this._selectedBangumiRow = this._bangumiRows[0];
    this._carousels = index.carousels;
    this._user = index.user;
  }

  List<BangumiRow> get bangumiRows => _bangumiRows;

  List<Carousel> get carousels => _carousels;

  List<YearSeason> get years => _years;

  User? get user => _user;

  loadSeason(final Season season) async {
    if (this._seasonLoading) return "加载中，请稍候".toast();
    this._selectedSeason = season;
    notifyListeners();
    this._seasonLoading = true;
    final Resp resp = await (this +
        Repo.season(this._selectedSeason!.year, this._selectedSeason!.season));
    this._seasonLoading = false;
    if (resp.success) {
      this._bangumiRows = resp.data;
      "加载完成".toast();
    } else {
      if (resp.msg.isNotBlank) {
        resp.msg.toast();
      } else {
        "加载失败".toast();
      }
    }
    notifyListeners();
  }
}

typedef LoadSeasonIndex = int Function(int currIndex);
