import 'package:collection/src/iterable_extensions.dart';
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
    if (_hasScrolled != value) {
      _hasScrolled = value;
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
  RefreshController(initialRefresh: false);

  RefreshController get refreshController => _refreshController;

  bool _ovaLoading = false;

  bool get ovaLoading => _ovaLoading;

  final SubscribedModel _subscribedModel;

  IndexModel(this._subscribedModel) {
    // 延迟执行
    Future.delayed(const Duration(milliseconds: 500), () {
      _ovas = (MyHive.db.get(HiveDBKey.mikanOva, defaultValue: <RecordItem>[])
      as List)
          .cast<RecordItem>();
      final Index? index = MyHive.db.get(HiveDBKey.mikanIndex);
      _bindIndexData(index);
      _loadIndex();
    });
  }

  refresh() async {
    await _loadIndex();
    await _loadOVA();
    _refreshController.refreshCompleted();
  }

  _loadOVA() async {
    _ovaLoading = true;
    notifyListeners();
    final Resp resp = await (this + Repo.ova());
    _ovaLoading = false;
    if (resp.success) {
      _ovas = resp.data;
      MyHive.db.put(HiveDBKey.mikanOva, _ovas);
    } else {
      "获取OVA失败：${resp.msg}".toast();
    }
    notifyListeners();
  }

  _loadIndex() async {
    _seasonLoading = true;
    notifyListeners();
    final Resp resp = await (this + Repo.index());
    _seasonLoading = false;
    if (resp.success) {
      final Index index = resp.data;
      MyHive.db.put(HiveDBKey.mikanIndex, index);
      _bindIndexData(index);
      "加载完成".toast();
    } else {
      "获取首页数据失败：${resp.msg}".toast();
    }
    notifyListeners();
  }

  void _bindIndexData(final Index? index) {
    if (index == null) return;
    _years = index.years;
    _bangumiRows = index.bangumiRows;
    _selectedBangumiRow = _bangumiRows[0];
    _carousels = index.carousels;
    _user = index.user;
    if (years.isSafeNotEmpty) {
      for (final YearSeason year in years) {
        _selectedSeason =
            year.seasons.firstWhereOrNull((element) => element.active);
        if (_selectedSeason != null) break;
      }
    }
    _subscribedModel.bindYearsAndSeason(_years, _selectedSeason);
  }

  List<BangumiRow> get bangumiRows => _bangumiRows;

  List<Carousel> get carousels => _carousels;

  List<YearSeason> get years => _years;

  User? get user => _user;

  loadSeason(final Season season) async {
    if (_seasonLoading) return "加载中，请稍候".toast();
    _selectedSeason = season;
    notifyListeners();
    _seasonLoading = true;
    final Resp resp = await (this +
        Repo.season(_selectedSeason!.year, _selectedSeason!.season));
    _seasonLoading = false;
    if (resp.success) {
      _bangumiRows = resp.data;
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

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

typedef LoadSeasonIndex = int Function(int currIndex);
