import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/bangumi_details.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BangumiDetailsModel extends CancelableBaseModel {
  final String id;
  final String cover;

  bool _loading = false;

  bool get loading => _loading;

  BangumiDetails _bangumiDetails;

  BangumiDetails get bangumiDetails => _bangumiDetails;

  Size coverSize;

  bool _hasScrolledSubgroupRecords = false;

  bool get hasScrolledSubgroupRecords => _hasScrolledSubgroupRecords;

  setScrolledSubgroupRecords(bool value) {
    if (this._hasScrolledSubgroupRecords != value) {
      _hasScrolledSubgroupRecords = value;
      notifyListeners();
    }
  }

  final RefreshController _refreshController = RefreshController();

  RefreshController get refreshController => _refreshController;

  BangumiDetailsModel(this.id, this.cover) {
    this._loadBangumiDetails();
    Future.delayed(
      Duration(milliseconds: 300),
      () => this._loadCoverMainColor(),
    );
  }

  SubgroupBangumi _subgroupBangumi;

  SubgroupBangumi get subgroupBangumi => _subgroupBangumi;

  set selectedSubgroupId(String value) {
    if (value == _subgroupBangumi?.subgroupId) {
      return;
    }
    _subgroupBangumi = _bangumiDetails.subgroupBangumis.firstWhere(
          (element) => element.subgroupId == value,
      orElse: () => null,
    );
    _hasScrolledSubgroupRecords = false;
    if (_refreshController.headerStatus != RefreshStatus.completed) {
      _refreshController.loadComplete();
    }
    notifyListeners();
  }

  Color _coverMainColor;

  Color get coverMainColor => _coverMainColor;

  _loadCoverMainColor() {
    PaletteGenerator.fromImageProvider(
      CachedNetworkImageProvider(this.cover, scale: 0.25),
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
    if (this._subgroupBangumi.records.length < 10) {
      return _refreshController.loadNoData();
    }
    final Resp resp = await (this +
        Repo.bangumiMore(
          this.id,
          this._subgroupBangumi.subgroupId,
          this._subgroupBangumi.records.length + 20,
        ));
    if (resp.success) {
      if (this._subgroupBangumi.records.length == resp.data.length) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
      this._subgroupBangumi.records = resp.data;
      notifyListeners();
    } else {
      _refreshController.loadFailed();
      resp.msg.toast();
    }
  }

  _loadBangumiDetails() async {
    this._loading = true;
    notifyListeners();
    final resp = await (this + Repo.bangumi(this.id));
    this._loading = false;
    if (resp.success) {
      _bangumiDetails = resp.data;
    } else {
      resp.msg?.toast();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    super.dispose();
  }
}
