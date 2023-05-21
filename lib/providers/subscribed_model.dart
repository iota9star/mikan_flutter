import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';

import '../internal/extension.dart';
import '../internal/http.dart';
import '../internal/repo.dart';
import '../model/bangumi.dart';
import '../model/record_item.dart';
import '../model/season.dart';
import '../model/year_season.dart';
import 'base_model.dart';

class SubscribedModel extends BaseModel {
  SubscribedModel();

  bool _seasonLoading = true;
  bool _recordsLoading = true;
  Season? _season;
  List<Bangumi>? _bangumis;
  Map<String, List<RecordItem>>? _rss;
  List<RecordItem>? _records;

  List<YearSeason>? _years;

  List<YearSeason>? get years => _years;

  void bindYearsAndSeason(List<YearSeason> years, Season? season) {
    _years = years;
    if (season != null) {
      _loadMySubscribedSeasonBangumi(season);
    }
  }

  Map<String, List<RecordItem>>? get rss => _rss;

  List<RecordItem>? get records => _records;

  bool get seasonLoading => _seasonLoading;

  bool get recordsLoading => _recordsLoading;

  Season? get season => _season;

  List<Bangumi>? get bangumis => _bangumis;

  Future<IndicatorResult> refresh() {
    return Future.wait(
      [_loadRecentRecords(), _loadMySubscribedSeasonBangumi(_season)],
    )
        .then((value) => IndicatorResult.success)
        .catchError((_) => IndicatorResult.fail);
  }

  Future<void> _loadMySubscribedSeasonBangumi(Season? season) async {
    if (season == null) {
      return;
    }
    _season = season;
    _seasonLoading = true;
    final Resp resp =
        await Repo.mySubscribedSeasonBangumi(season.year, season.season);
    _seasonLoading = false;
    if (resp.success) {
      _bangumis = resp.data;
    } else {
      '获取季度订阅失败 ${resp.msg ?? ''}'.toast();
    }
    notifyListeners();
  }

  Future<void> _loadRecentRecords() async {
    _recordsLoading = true;
    final Resp resp = await Repo.day(2, 1);
    _recordsLoading = false;
    if (resp.success) {
      _records = resp.data ?? [];
      _rss = groupBy(resp.data ?? [], (it) => it.id!);
    } else {
      '获取最近更新失败 ${resp.msg ?? ''}'.toast();
    }
    notifyListeners();
  }
}
