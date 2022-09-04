import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RecentSubscribedModel extends CancelableBaseModel {
  bool _recordsLoading = false;

  List<RecordItem> _records;

  int _dayOffset = 2;

  List<RecordItem> get records => _records;

  bool get recordsLoading => _recordsLoading;

  bool _isRefresh = false;

  final RefreshController _refreshController = RefreshController();

  RefreshController get refreshController => _refreshController;

  RecentSubscribedModel(this._records);

  refresh() async {
    _dayOffset = 0;
    _isRefresh = true;
    await loadMore();
  }

  loadMore() async {
    final int next = _dayOffset + 3;
    _recordsLoading = true;
    final Resp resp = await (this + Repo.day(next, 1));
    _recordsLoading = false;
    if (resp.success) {
      final List<RecordItem> data = resp.data ?? [];
      if (_isRefresh) {
        _refreshController.refreshCompleted();
      } else {
        // recent 14 days.
        if (next > 14 && data.length == _records.length) {
          _refreshController.loadNoData();
        } else {
          _refreshController.loadComplete();
        }
      }
      _dayOffset = next;
      _records = data;
      notifyListeners();
    } else {
      _refreshController.failed();
      "获取最近更新失败：${resp.msg}".toast();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
