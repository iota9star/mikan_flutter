import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/core/repo.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/model/bangumi_details.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class BangumiDetailsModel extends CancelableBaseModel {
  final String id;
  final String cover;

  bool _loading = false;

  bool get loading => _loading;

  BangumiDetails _bangumiDetails;

  BangumiDetails get bangumiDetails => _bangumiDetails;

  Size coverSize;

  final PanelController _panelController = PanelController();

  final RefreshController _refreshController = RefreshController();

  PanelController get panelController => _panelController;

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
    _subgroupBangumi = _bangumiDetails.subgroupBangumis.firstWhere(
            (element) => element.subgroupId == value,
        orElse: () => null);
    if (_refreshController.headerStatus != RefreshStatus.completed) {
      _refreshController.loadComplete();
    }
    _refreshController.resetNoData();
    notifyListeners();
    _panelController.animatePanelToPosition(
      1.0,
      duration: Duration(
        milliseconds: 240,
      ),
    );
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

  loadSubgroupList() {
    if (this._subgroupBangumi.records.length < 10) {
      return _refreshController.loadNoData();
    }
    Repo.bangumiMore(
      this.id,
      this._subgroupBangumi.subgroupId,
      this._subgroupBangumi.records.length + 20,
    ).then((resp) {
      if (resp.success) {
        if (this._subgroupBangumi.records.length == resp.data.length) {
          _refreshController.loadNoData();
        }
        this._subgroupBangumi.records = resp.data;
      } else {
        _refreshController.loadFailed();
        resp.msg.toast();
      }
    }).whenComplete(() {
      if (_refreshController.headerStatus != RefreshStatus.completed) {
        _refreshController.loadComplete();
      }
      this.notifyListeners();
    });
  }

  _loadBangumiDetails() {
    this._loading = true;
    Repo.bangumi(this.id).then((resp) {
      if (resp.success) {
        _bangumiDetails = resp.data;
      } else {
        resp.msg?.toast();
      }
    }).whenComplete(() {
      this._loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
