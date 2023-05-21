import 'package:easy_refresh/easy_refresh.dart';

import '../internal/extension.dart';
import '../internal/repo.dart';
import '../model/season_gallery.dart';
import '../model/subgroup.dart';
import 'base_model.dart';

class SubgroupModel extends BaseModel {
  SubgroupModel(this.subgroup);

  final Subgroup subgroup;

  List<SeasonGallery> _galleries = [];

  List<SeasonGallery> get galleries => _galleries;

  Future<IndicatorResult> refresh() async {
    final resp = await Repo.subgroup(subgroup.id);
    if (resp.success) {
      _galleries = resp.data;
      notifyListeners();
      '加载成功'.toast();
      return IndicatorResult.success;
    } else {
      '加载字幕组作品年表失败 ${resp.msg ?? ''}'.toast();
      return IndicatorResult.fail;
    }
  }
}
