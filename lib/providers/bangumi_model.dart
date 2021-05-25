import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/bangumi_details.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BangumiModel extends CancelableBaseModel {
  final String id;
  final String cover;

  bool _loading = false;

  bool get loading => _loading;

  BangumiDetail? _bangumiDetail;

  BangumiDetail? get bangumiDetail => _bangumiDetail;

  Size? coverSize;

  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (this._hasScrolled != value) {
      _hasScrolled = value;
      notifyListeners();
    }
  }

  final RefreshController _refreshController = RefreshController();

  RefreshController get refreshController => _refreshController;

  BangumiModel(this.id, this.cover) {
    this._loadBangumiDetail();
    Future.delayed(Duration(milliseconds: 640))
        .whenComplete(() => this._loadCoverMainColor());
  }

  SubgroupBangumi? _subgroupBangumi;

  SubgroupBangumi? get subgroupBangumi => _subgroupBangumi;

  set selectedSubgroupId(String value) {
    if (value == _subgroupBangumi?.dataId) {
      return;
    }
    _subgroupBangumi = _bangumiDetail?.subgroupBangumis
        .firstWhere((element) => element.dataId == value);
    _hasScrolled = false;
    if (_refreshController.headerStatus != RefreshStatus.completed) {
      _refreshController.loadComplete();
    }
    notifyListeners();
  }

  Color? _coverMainColor;

  Color? get coverMainColor => _coverMainColor;

  _loadCoverMainColor() {
    PaletteGenerator.fromImageProvider(
      ExtendedNetworkImageProvider(this.cover),
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

  loadSubgroupList() async {
    if ((this._subgroupBangumi?.records.length ?? 0) < 10) {
      return _refreshController.loadNoData();
    }
    final Resp resp = await (this +
        Repo.bangumiMore(
          this.id,
          this._subgroupBangumi?.dataId ?? "",
          this._subgroupBangumi?.records.length ?? 0 + 20,
        ));
    if (resp.success) {
      if (this._subgroupBangumi?.records.length == resp.data.length) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
      this._subgroupBangumi?.records = resp.data;
      notifyListeners();
    } else {
      _refreshController.loadFailed();
      resp.msg.toast();
    }
  }

  _loadBangumiDetail() async {
    this._loading = true;
    notifyListeners();
    final resp = await (this + Repo.bangumi(this.id));
    this._loading = false;
    if (resp.success) {
      _bangumiDetail = resp.data;
    } else {
      resp.msg?.toast();
    }
    notifyListeners();
  }
}
