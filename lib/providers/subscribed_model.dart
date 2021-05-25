import "package:collection/collection.dart";
import 'package:flutter/foundation.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SubscribedModel extends CancelableBaseModel {
  bool _seasonLoading = true;
  bool _recordsLoading = true;
  Season? _season;
  List<Bangumi>? _bangumis;
  Map<String, List<RecordItem>>? _rss;
  List<RecordItem>? _records;

  List<YearSeason>? _years;

  List<YearSeason>? get years => _years;

  set years(List<YearSeason>? years) {
    this._years = years;
    if (years.isSafeNotEmpty) {
      this._loadMySubscribedSeasonBangumi(years![0].seasons.first);
    }
  }

  Map<String, List<RecordItem>>? get rss => _rss;

  List<RecordItem>? get records => _records;

  bool get seasonLoading => _seasonLoading;

  bool get recordsLoading => _recordsLoading;

  Season? get season => _season;

  List<Bangumi>? get bangumis => _bangumis;

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
    this._loadRecentRecords();
  }

  refresh() async {
    await this._loadRecentRecords();
    await this._loadMySubscribedSeasonBangumi(this._season);
    _refreshController.refreshCompleted();
  }

  _loadMySubscribedSeasonBangumi(final Season? season) async {
    if (season == null) return;
    this._season = season;
    this._seasonLoading = true;
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

  _loadRecentRecords() async {
    this._recordsLoading = true;
    final Resp resp = await (this + Repo.day(2, 1));
    this._recordsLoading = false;
    if (resp.success) {
      this._records = resp.data ?? [];
      this._rss = groupBy(resp.data ?? [], (it) => it.id!);
    } else {
      "获取最近更新失败：${resp.msg}".toast();
    }
    notifyListeners();
  }

  subscribeBangumi(
    final String bangumiId,
    final bool subscribed, {
    final String? subgroupId,
    final VoidCallback? onSuccess,
    final ValueChanged<String?>? onError,
  }) async {
    if (bangumiId.isNullOrBlank) {
      return "番组id为空，忽略当前订阅".toast();
    }
    final int? bid = int.tryParse(bangumiId);
    if (bid == null) {
      return "番组id为空，忽略当前订阅".toast();
    }
    int? sid;
    if (subgroupId.isNotBlank) {
      sid = int.tryParse(subgroupId!);
      if (sid == null) {
        return "字幕组id解析错误，忽略当前订阅".toast();
      }
    }
    final Resp resp = await (this +
        Repo.subscribeBangumi(
          bid,
          subscribed,
          subgroupId: sid,
        ));
    if (resp.success) {
      onSuccess?.call();
    } else {
      onError?.call(resp.msg);
    }
  }
}
