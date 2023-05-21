import 'package:easy_refresh/easy_refresh.dart';

import '../internal/extension.dart';
import '../internal/repo.dart';
import '../model/bangumi_row.dart';
import '../model/season.dart';
import 'base_model.dart';

class SeasonModel extends BaseModel {
  SeasonModel(this._season);

  final Season _season;

  List<BangumiRow> _bangumiRows = [];

  List<BangumiRow> get bangumiRows => _bangumiRows;

  Future<IndicatorResult> refresh() async {
    final resp = await Repo.season(_season.year, _season.season);
    if (resp.success) {
      _bangumiRows = resp.data ?? [];
      notifyListeners();
      return IndicatorResult.success;
    } else {
      '获取${_season.title}失败 ${resp.msg ?? ''}'.toast();
      return IndicatorResult.fail;
    }
  }
}
