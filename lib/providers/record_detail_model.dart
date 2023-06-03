import 'package:easy_refresh/easy_refresh.dart';

import '../internal/extension.dart';
import '../internal/repo.dart';
import '../model/record_details.dart';
import 'base_model.dart';

class RecordDetailModel extends BaseModel {
  RecordDetailModel(this.url);

  final String url;

  RecordDetail? _recordDetail;

  RecordDetail? get recordDetail => _recordDetail;

  Future<IndicatorResult> refresh() async {
    final resp = await Repo.details(url);
    if (resp.success) {
      _recordDetail = resp.data;
      '加载完成'.toast();
      notifyListeners();
      return IndicatorResult.success;
    } else {
      '获取详情失败 ${resp.msg ?? ''}'.toast();
      return IndicatorResult.fail;
    }
  }

  void subscribeChanged() {
    notifyListeners();
  }
}
