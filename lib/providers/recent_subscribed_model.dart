import 'package:easy_refresh/easy_refresh.dart';

import '../internal/extension.dart';
import '../internal/repo.dart';
import '../model/record_item.dart';
import 'base_model.dart';

class RecentSubscribedModel extends BaseModel {
  RecentSubscribedModel(this._records);

  List<RecordItem> _records;

  int _dayOffset = 2;

  List<RecordItem> get records => _records;

  bool _isRefresh = false;

  Future<IndicatorResult> refresh() {
    _dayOffset = 0;
    _isRefresh = true;
    return loadMore();
  }

  Future<IndicatorResult> loadMore() async {
    final next = _dayOffset + 3;
    final resp = await Repo.day(next, 1);
    if (resp.success) {
      final data = resp.data ?? [];
      _dayOffset = next;
      _records = data;
      notifyListeners();
      if (_isRefresh) {
        return IndicatorResult.success;
      } else {
        // recent 14 days.
        if (next > 14 && data.length == _records.length) {
          return IndicatorResult.noMore;
        } else {
          return IndicatorResult.success;
        }
      }
    } else {
      '获取最近更新失败：${resp.msg}'.toast();
      return IndicatorResult.fail;
    }
  }
}
