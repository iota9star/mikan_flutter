import "package:collection/collection.dart";
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SubscribedModel extends CancelableBaseModel {
  bool _seasonLoading = false;
  bool _recordsLoading = false;
  Season _season;
  List<Bangumi> _bangumis;
  Map<String, List<RecordItem>> _rss;
  List<RecordItem> _records;
  int _tapRecordItemIndex;

  int get tapRecordItemIndex => _tapRecordItemIndex;

  set tapRecordItemIndex(int value) {
    _tapRecordItemIndex = value;
    notifyListeners();
  }

  Map<String, List<RecordItem>> get rss => _rss;

  List<RecordItem> get records => _records;

  bool get seasonLoading => _seasonLoading;

  bool get recordsLoading => _recordsLoading;

  Season get season => _season;

  List<Bangumi> get bangumis => _bangumis;

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

  SubscribedModel() {
    this.loadRecentRecords();
  }

  refresh() async {
    await this.loadRecentRecords();
    await this.loadMySubscribedSeasonBangumi(this._season);
    _refreshController.refreshCompleted();
    "刷新结束".toast();
  }

  loadMySubscribedSeasonBangumi(final Season season) async {
    if (season == null) return;
    this._season = season;
    this._seasonLoading = true;
    notifyListeners();
    final Resp resp = await (this +
        Repo.mySubscribedSeasonBangumi(season.year, season.season));
    this._seasonLoading = false;
    if (resp.success) {
      this._bangumis = resp.data;
    } else {
      "获取季度订阅失败：${resp.msg}".toast();
    }
    notifyListeners();
  }

  loadRecentRecords() async {
    this._recordsLoading = true;
    notifyListeners();
    final Resp resp = await (this + Repo.day(2, 1));
    if (resp.success) {
      this._records = resp.data ?? [];
      this._rss = groupBy(resp.data ?? [], (it) => it.id);
    } else {
      "获取最近更新失败：${resp.msg}".toast();
    }
  }
}
