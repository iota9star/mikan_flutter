import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/providers/view_models/base_model.dart';

class OpModel extends CancelableBaseModel {
  String _rebuildFlag;

  String get rebuildFlag => _rebuildFlag;

  set rebuildFlag(String value) {
    _rebuildFlag = value;
    notifyListeners();
  }

  performTap(final String flag) {
    this.rebuildFlag = flag;
    Future.delayed(Duration(milliseconds: 960), () => this.rebuildFlag = null);
  }

  subscribeBangumi(
    final String bangumiId,
    final bool subscribed, {
    final String subgroupId,
    final VoidCallback onSuccess,
    final ValueChanged<String> onError,
  }) async {
    if (bangumiId.isNullOrBlank) {
      return "番组id为空，忽略当前订阅".toast();
    }
    final int bid = int.tryParse(bangumiId);
    if (bid == null) {
      return "番组id为空，忽略当前订阅".toast();
    }
    int sid;
    if (subgroupId.isNotBlank) {
      sid = int.tryParse(subgroupId);
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
