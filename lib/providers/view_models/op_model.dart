import 'package:dio/dio.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/providers/view_models/base_model.dart';

class OpModel extends CancelableBaseModel {
  subscribeBangumi(
    final String bangumiId,
    final bool subscribed, {
    final String subgroupId,
    final VoidCallback onSuccess,
    final VoidCallback onError,
  }) async {
    final Resp resp = await (this +
        Repo.subscribeBangumi(
          bangumiId,
          subscribed,
          subgroupId: subgroupId,
        ));
    if (resp.success) {
      onSuccess?.call();
    } else {
      onError?.call();
    }
  }
}
