import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListModel extends CancelableBaseModel {
  int _page = 0;
  List<RecordItem> _records = [];
  int _tapRecordItemIndex = -1;

  set tapRecordItemIndex(int value) {
    _tapRecordItemIndex = value;
    notifyListeners();
  }

  int get tapRecordItemIndex => _tapRecordItemIndex;

  int get recordsLength => _records.length;

  List<RecordItem> get records => _records;

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

  ListModel() {
    this.refresh();
  }

  loadMore() async {
    await (this + _loadList(this._page));
  }

  Future refresh() async {
    await (this + _loadList(0));
  }

  Future _loadList(final int page) async {
    final int willLoadPage = page + 1;
    final Resp resp = await (this + Repo.list(willLoadPage));
    if (resp.success) {
      this._refreshController.completed();
      final List<RecordItem> records = resp.data;
      if (records.isNullOrEmpty) {
        return "未获取到数据...".toast();
      }
      if (willLoadPage == 1 && this._records.isNotEmpty) {
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
      this._page = willLoadPage;
    } else {
      this._refreshController.failed();
    }
  }

  @override
  void dispose() {
    _records = null; // 数据量大手动清掉
    _refreshController?.dispose();
    super.dispose();
  }
}
