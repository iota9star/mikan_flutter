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

  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (this._hasScrolled != value) {
      this._hasScrolled = value;
      notifyListeners();
    }
  }

  final RefreshController _refreshController = RefreshController();

  RefreshController get refreshController => _refreshController;

  RecentSubscribedModel(this._records);

  refresh() async {
    this._dayOffset = 0;
    await this.loadMoreRecentRecords();
  }

  loadMoreRecentRecords() async {
    final int next = this._dayOffset + 2;
    final Resp resp = await (this + Repo.day(next, 1));
    if (resp.success) {
      final List<RecordItem> data = resp.data ?? [];
      final noMore = data.length == this._records.length;
      this._refreshController.completed(noMore: noMore);
      if (noMore) return;
      this._dayOffset = next;
      this._records = data;
      notifyListeners();
    } else {
      this._refreshController.failed();
      "获取最近更新失败：${resp.msg}".toast();
    }
  }
}
