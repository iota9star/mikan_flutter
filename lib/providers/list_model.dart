import 'package:easy_refresh/easy_refresh.dart';

import '../internal/extension.dart';
import '../internal/repo.dart';
import '../model/record_item.dart';
import 'base_model.dart';

class ListModel extends BaseModel {
  ListModel();

  int _page = 0;
  List<RecordItem> _records = [];

  List<RecordItem> get records => _records;

  int _changeFlag = 0;

  int get changeFlag => _changeFlag;

  Future<IndicatorResult> loadMore() {
    return _loadList();
  }

  Future<IndicatorResult> refresh() {
    _page = 0;
    return _loadList();
  }

  Future<IndicatorResult> _loadList() async {
    final resp = await Repo.list(_page + 1);
    if (resp.success) {
      final List<RecordItem> records = resp.data;
      if (records.isNullOrEmpty) {
        '未获取到数据'.toast();
        return IndicatorResult.none;
      }
      if (_page == 0 && _records.isNotEmpty) {
        final Set<RecordItem> newList = <RecordItem>{..._records, ...records};
        final int length = newList.length;
        if (length == _records.length) {
          '无内容更新'.toast();
        } else {
          '更新数据${length - _records.length}条'.toast();
          _records = newList.toList();
          _changeFlag++;
          notifyListeners();
        }
      } else {
        _records.addAll(records);
        _changeFlag++;
        notifyListeners();
      }
      _page++;
      return IndicatorResult.success;
    } else {
      return IndicatorResult.fail;
    }
  }
}
