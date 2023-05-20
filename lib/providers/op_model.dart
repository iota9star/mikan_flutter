import 'package:flutter/cupertino.dart';

import '../internal/extension.dart';
import '../internal/http.dart';
import '../internal/repo.dart';
import 'base_model.dart';

class OpModel extends BaseModel {
  Future<void> subscribeBangumi(
    String bangumiId,
    bool subscribed, {
    String? subgroupId,
    VoidCallback? onSuccess,
    ValueChanged<String?>? onError,
  }) async {
    if (bangumiId.isNullOrBlank) {
      return '番组id为空，忽略当前订阅'.toast();
    }
    final int? bid = int.tryParse(bangumiId);
    if (bid == null) {
      return '番组id为空，忽略当前订阅'.toast();
    }
    int? sid;
    if (subgroupId.isNotBlank) {
      sid = int.tryParse(subgroupId!);
      if (sid == null) {
        return '字幕组id解析错误，忽略当前订阅'.toast();
      }
    }
    final Resp resp =
        await Repo.subscribeBangumi(bid, subscribed, subgroupId: sid);
    if (resp.success) {
      onSuccess?.call();
    } else {
      onError?.call(resp.msg);
    }
  }

  String _flag = '';

  String get flag => _flag;

  void subscribeChanged(String flag) {
    _flag = flag;
    notifyListeners();
  }
}
