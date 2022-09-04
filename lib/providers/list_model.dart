import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListModel extends CancelableBaseModel {
  int _page = 0;
  List<RecordItem> _records = [];

  List<RecordItem> get records => _records;

  int _changeFlag = 0;

  int get changeFlag => _changeFlag;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  RefreshController get refreshController => _refreshController;

  loadMore() async {
    await (this + _loadList());
  }

  Future refresh() async {
    _page = 0;
    await (this + _loadList());
  }

  Future _loadList() async {
    final Resp resp = await (this + Repo.list(_page + 1));
    if (resp.success) {
      _refreshController.completed();
      final List<RecordItem> records = resp.data;
      if (records.isNullOrEmpty) {
        return "未获取到数据".toast();
      }
      if (_page == 0 && _records.isNotEmpty) {
        final Set<RecordItem> newList = <RecordItem>{..._records, ...records};
        final int length = newList.length;
        if (length == _records.length) {
          "无内容更新".toast();
        } else {
          "更新数据${length - _records.length}条".toast();
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
    } else {
      _refreshController.failed();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
