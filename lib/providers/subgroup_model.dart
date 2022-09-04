import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/season_gallery.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SubgroupModel extends CancelableBaseModel {
  final Subgroup subgroup;
  bool _loading = false;

  bool get loading => _loading;

  SubgroupModel(this.subgroup) {
    _loading = true;
    _loadBangumis();
  }

  List<SeasonGallery> _galleries = [];

  List<SeasonGallery> get galleries => _galleries;

  final RefreshController _refreshController = RefreshController();

  RefreshController get refreshController => _refreshController;

  _loadBangumis() async {
    final Resp resp = await (this + Repo.subgroup(subgroup.id));
    _loading = false;
    if (resp.success) {
      _galleries = resp.data;
    } else {
      "加载字幕组作品年表失败：${resp.msg}".toast();
    }
    notifyListeners();
  }

  refresh() async {
    if (_loading) return _refreshController.refreshCompleted();
    await _loadBangumis();
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
