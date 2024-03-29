import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';

import '../internal/extension.dart';
import '../internal/hive.dart';
import '../internal/repo.dart';
import '../model/announcement.dart';
import '../model/bangumi_row.dart';
import '../model/carousel.dart';
import '../model/index.dart';
import '../model/record_item.dart';
import '../model/season.dart';
import '../model/user.dart';
import '../model/year_season.dart';
import 'base_model.dart';
import 'subscribed_model.dart';

class IndexModel extends BaseModel {
  IndexModel(this._subscribedModel) {
    _ovas = (MyHive.db.get(HiveDBKey.mikanOva, defaultValue: <RecordItem>[])
            as List)
        .cast<RecordItem>();
    final index = MyHive.db.get(HiveDBKey.mikanIndex);
    _bindIndexData(index);
    refresh();
  }

  List<YearSeason> _years = [];
  List<BangumiRow> _bangumiRows = [];
  List<RecordItem> _ovas = [];
  List<Carousel> _carousels = [];
  Season? _selectedSeason;
  User? _user;
  List<Announcement>? _announcements;
  BangumiRow? _selectedBangumiRow;

  BangumiRow? get selectedBangumiRow => _selectedBangumiRow;

  set selectedBangumiRow(BangumiRow? value) {
    _selectedBangumiRow = value;
    notifyListeners();
  }

  Season? get selectedSeason => _selectedSeason;

  List<Announcement>? get announcements => _announcements;

  List<RecordItem> get ovas => _ovas;

  final SubscribedModel _subscribedModel;

  Completer<IndicatorResult>? _completer;

  Future<IndicatorResult> refresh() {
    if (_completer != null) {
      return _completer!.future;
    }
    final completer = Completer<IndicatorResult>();
    _completer = completer;
    Future.wait([_loadIndex(), _loadOVA()])
        .then((_) => completer.complete(IndicatorResult.success))
        .catchError((_) => completer.complete(IndicatorResult.fail))
        .whenComplete(() => _completer = null);
    return completer.future;
  }

  Future<void> _loadOVA() async {
    final resp = await Repo.ova();
    if (resp.success) {
      _ovas = resp.data;
      unawaited(MyHive.db.put(HiveDBKey.mikanOva, _ovas));
    } else {
      '获取OVA失败 ${resp.msg ?? ''}'.toast();
    }
    notifyListeners();
  }

  Future<void> _loadIndex() async {
    final resp = await Repo.index();
    if (resp.success) {
      final index = resp.data;
      unawaited(MyHive.db.put(HiveDBKey.mikanIndex, index));
      _bindIndexData(index);
      '加载完成'.toast();
      notifyListeners();
    } else {
      '获取首页数据失败 ${resp.msg ?? ''}'.toast();
    }
  }

  void _bindIndexData(Index? index) {
    if (index == null) {
      return;
    }
    _years = index.years;
    _bangumiRows = index.bangumiRows;
    _selectedBangumiRow = _bangumiRows[0];
    _carousels = index.carousels;
    _user = index.user;
    _announcements = index.announcements;
    if (years.isSafeNotEmpty) {
      for (final YearSeason year in years) {
        _selectedSeason =
            year.seasons.firstWhereOrNull((element) => element.active);
        if (_selectedSeason != null) {
          break;
        }
      }
    }
    _subscribedModel.bindYearsAndSeason(_years, _selectedSeason);
  }

  List<BangumiRow> get bangumiRows => _bangumiRows;

  List<Carousel> get carousels => _carousels;

  List<YearSeason> get years => _years;

  User? get user => _user;

  Future<void> selectSeason(Season season) async {
    _selectedSeason = season;
    notifyListeners();
    final resp = await Repo.season(
      _selectedSeason!.year,
      _selectedSeason!.season,
    );
    if (resp.success) {
      _bangumiRows = resp.data;
      '加载完成'.toast();
      notifyListeners();
    } else {
      if (resp.msg.isNotBlank) {
        resp.msg.toast();
      } else {
        '加载失败'.toast();
      }
    }
  }
}

typedef LoadSeasonIndex = int Function(int currIndex);
