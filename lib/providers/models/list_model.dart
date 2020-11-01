import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListModel extends CancelableBaseModel {
  int _page = 0;
  List<RecordItem> _records = [];
  int _scaleIndex = -1;

  set scaleIndex(int value) {
    _scaleIndex = value;
    notifyListeners();
  }

  int get scaleIndex => _scaleIndex;

  int get recordsLength => _records.length;

  List<RecordItem> get records => _records;

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
    final Resp resp = await Repo.list(willLoadPage);
    if (this.disposed) return;
    this._refreshController.refreshCompleted();
    if (resp.success) {
      final List<RecordItem> records = resp.data ?? [];
      if (records.isEmpty) {
        return "未获取到数据...".toast();
      }
      if (willLoadPage == 1 && this._records.isNotEmpty) {
        final Set<RecordItem> newList = [...this._records, ...records].toSet();
        final int length = newList.length;
        if (length == this._records.length) {
          "无内容更新".toast();
        } else {
          "更新数据${length - this._records.length}条".toast();
          this._records = [];
          notifyListeners();
          this._records = newList.toList();
        }
      } else {
        this._records.addAll(records);
        notifyListeners();
      }
      this._page = willLoadPage;
    }
  }

  final double _maxScrollOffset = 56.0;
  double _limit = 0;

  double get limit => _limit;

  Future notifyOffsetChange(final double offset) async {
    if (offset >= _maxScrollOffset) {
      if (_limit != 1.0) {
        _limit = 1.0;
        notifyListeners();
      }
    } else if (offset <= _maxScrollOffset && offset >= 0) {
      if (_limit != offset / _maxScrollOffset) {
        _limit = offset / _maxScrollOffset;
        notifyListeners();
      }
    } else if (offset <= 0) {
      if (_limit != 0.0) {
        _limit = 0.0;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _records = null; // 数据量大手动清掉
    _refreshController.dispose();
    super.dispose();
  }
}
