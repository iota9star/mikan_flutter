import 'package:easy_refresh/easy_refresh.dart';

import '../internal/extension.dart';
import '../internal/repo.dart';
import '../model/record_details.dart';
import '../model/record_item.dart';
import 'base_model.dart';

class RecordDetailModel extends BaseModel {
  RecordDetailModel(this.record)
      : _recordDetail = RecordDetail()
          ..name = record.name
          ..url = record.url
          ..title = record.title
          ..subgroups = record.groups
          ..id = record.id
          ..cover = record.cover
          ..tags = record.tags
          ..torrent = record.torrent
          ..magnet = record.magnet;

  final RecordItem record;

  RecordDetail _recordDetail;

  RecordDetail get recordDetail => _recordDetail;

  Future<IndicatorResult> refresh() async {
    final resp = await Repo.details(record.url);
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
