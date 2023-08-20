import 'dart:async';
import 'dart:ui';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import '../internal/extension.dart';
import '../internal/repo.dart';
import '../model/bangumi_details.dart';
import 'base_model.dart';

class BangumiModel extends BaseModel {
  BangumiModel(this.id, this.cover);

  final String id;
  final String cover;

  int _refreshFlag = 0;

  int get refreshFlag => _refreshFlag;

  BangumiDetail? _bangumiDetail;

  BangumiDetail? get bangumiDetail => _bangumiDetail;

  Size? coverSize;

  Future<IndicatorResult> loadSubgroupList(String dataId) async {
    final sb = _bangumiDetail?.subgroupBangumis[dataId];
    if ((sb?.records.length ?? 0) < 10) {
      return IndicatorResult.noMore;
    }
    final resp = await Repo.bangumiMore(
      id,
      sb?.dataId ?? '',
      (sb?.records.length ?? 0) + 20,
    );
    if (resp.success) {
      if (sb?.records.length == resp.data.length) {
        return IndicatorResult.noMore;
      } else {
        sb?.records = resp.data;
        notifyListeners();
        return IndicatorResult.success;
      }
    } else {
      resp.msg.toast();
      return IndicatorResult.fail;
    }
  }

  Future<IndicatorResult> load() async {
    final resp = await Repo.bangumi(id);
    if (resp.success) {
      _bangumiDetail = resp.data;
      '加载完成'.toast();
      _refreshFlag++;
      notifyListeners();
      return IndicatorResult.success;
    } else {
      resp.msg.toast();
      return IndicatorResult.fail;
    }
  }

  Future<void> changeSubscribe() async {
    if (_bangumiDetail == null) {
      return;
    }
    final bangumiId = _bangumiDetail!.id;
    if (bangumiId.isNullOrBlank) {
      return '番组id为空，忽略当前订阅'.toast();
    }
    final int? bid = int.tryParse(bangumiId);
    if (bid == null) {
      return '番组id为空，忽略当前订阅'.toast();
    }
    final resp = await Repo.subscribeBangumi(
      bid,
      _bangumiDetail!.subscribed,
    );
    if (resp.success) {
      notifyListeners();
      await load();
    } else {
      return resp.msg.toast();
    }
  }
}
