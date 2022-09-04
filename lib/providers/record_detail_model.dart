import 'dart:ui';

import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/record_details.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RecordDetailModel extends CancelableBaseModel {
  final String url;

  Size? coverSize;

  RecordDetail? _recordDetail;

  RecordDetail? get recordDetail => _recordDetail;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  RefreshController get refreshController => _refreshController;

  RecordDetailModel(this.url);

  Color? _coverMainColor;

  Color? get coverMainColor => _coverMainColor;

  refresh() async {
    final Resp resp = await (this + Repo.details(url));
    _refreshController.refreshCompleted();
    if (resp.success) {
      _recordDetail = resp.data;
      "加载成功".toast();
    } else {
      "获取详情失败：${resp.msg}".toast();
    }
    notifyListeners();
  }

  subscribeChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
