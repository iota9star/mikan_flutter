import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SeasonModel extends CancelableBaseModel {
  final Season _season;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  List<BangumiRow> _bangumiRows = [];

  List<BangumiRow> get bangumiRows => _bangumiRows;

  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (this._hasScrolled != value) {
      this._hasScrolled = value;
      notifyListeners();
    }
  }

  RefreshController get refreshController => _refreshController;

  SeasonModel(this._season);

  refresh() async {
    final Resp resp =
        await (this + Repo.season(this._season.year, this._season.season));
    _refreshController.completed();
    if (resp.success) {
      this._bangumiRows = resp.data ?? [];
      notifyListeners();
    } else {
      "获取${this._season.title}失败：${resp.msg}".toast();
    }
  }
}
