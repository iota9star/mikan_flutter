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

  @override
  void notifyListeners() {
    this._changeFlag++;
    super.notifyListeners();
  }

  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (this._hasScrolled != value) {
      this._hasScrolled = value;
      notifyListeners();
    }
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  RefreshController get refreshController => _refreshController;

  loadMore() async {
    await (this + _loadList());
  }

  Future refresh() async {
    this._page = 0;
    await (this + _loadList());
  }

  Future _loadList() async {
    final Resp resp = await (this + Repo.list(this._page + 1));
    if (resp.success) {
      this._refreshController.completed();
      final List<RecordItem> records = resp.data;
      if (records.isNullOrEmpty) {
        return "未获取到数据".toast();
      }
      if (this._page == 0 && this._records.isNotEmpty) {
        final Set<RecordItem> newList = [...this._records, ...records].toSet();
        final int length = newList.length;
        if (length == this._records.length) {
          "无内容更新".toast();
        } else {
          "更新数据${length - this._records.length}条".toast();
          this._records = newList.toList();
          notifyListeners();
        }
      } else {
        this._records.addAll(records);
        notifyListeners();
      }
      this._page++;
    } else {
      this._refreshController.failed();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
