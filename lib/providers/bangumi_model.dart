import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/bangumi_details.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BangumiModel extends CancelableBaseModel {
  final String id;
  final String cover;

  int _refreshFlag = 0;

  int get refreshFlag => _refreshFlag;

  BangumiDetail? _bangumiDetail;

  BangumiDetail? get bangumiDetail => _bangumiDetail;

  Size? coverSize;

  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (_hasScrolled != value) {
      _hasScrolled = value;
      notifyListeners();
    }
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  RefreshController get refreshController => _refreshController;

  final RefreshController _subgroupRefreshController = RefreshController();

  RefreshController get subgroupRefreshController => _subgroupRefreshController;

  BangumiModel(this.id, this.cover) {
    Future.delayed(const Duration(milliseconds: 640))
        .whenComplete(() => _loadCoverMainColor());
  }

  Color? _coverMainColor;

  Color? get coverMainColor => _coverMainColor;

  _loadCoverMainColor() {
    PaletteGenerator.fromImageProvider(
      FastCacheImage(cover),
      maximumColorCount: 3,
      targets: [
        PaletteTarget.lightVibrant,
        PaletteTarget.vibrant,
      ],
    ).then((value) {
      _coverMainColor = value.lightVibrantColor?.color ??
          value.vibrantColor?.color ??
          value.colors.getOrNull(0);
      if (_coverMainColor != null) {
        notifyListeners();
      }
    });
  }

  loadSubgroupList(final String dataId) async {
    final sb = _bangumiDetail?.subgroupBangumis[dataId];
    if ((sb?.records.length ?? 0) < 10) {
      return _subgroupRefreshController.loadNoData();
    }
    final Resp resp = await (this +
        Repo.bangumiMore(
          id,
          sb?.dataId ?? "",
          (sb?.records.length ?? 0) + 20,
        ));
    if (resp.success) {
      if (sb?.records.length == resp.data.length) {
        _subgroupRefreshController.loadNoData();
      } else {
        _subgroupRefreshController.loadComplete();
      }
      sb?.records = resp.data;
      notifyListeners();
    } else {
      _subgroupRefreshController.loadFailed();
      resp.msg.toast();
    }
  }

  load() async {
    final resp = await (this + Repo.bangumi(id));
    _refreshController.refreshCompleted();
    if (resp.success) {
      _bangumiDetail = resp.data;
      "加载成功".toast();
    } else {
      resp.msg?.toast();
    }
    _refreshFlag++;
    notifyListeners();
  }

  Future<void> changeSubscribe() async {
    if (_bangumiDetail == null) return;
    final bangumiId = _bangumiDetail!.id;
    if (bangumiId.isNullOrBlank) {
      return "番组id为空，忽略当前订阅".toast();
    }
    final int? bid = int.tryParse(bangumiId);
    if (bid == null) {
      return "番组id为空，忽略当前订阅".toast();
    }
    final Resp resp = await (this +
        Repo.subscribeBangumi(
          bid,
          _bangumiDetail!.subscribed,
        ));
    if (resp.success) {
      _bangumiDetail!.subscribed = !_bangumiDetail!.subscribed;
    } else {
      return resp.msg.toast();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _subgroupRefreshController.dispose();
    super.dispose();
  }
}
