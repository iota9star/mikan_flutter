import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/model/subgroup_gallery.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';

class SubgroupModel extends CancelableBaseModel {
  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (this._hasScrolled != value) {
      this._hasScrolled = value;
      notifyListeners();
    }
  }

  int _tapBangumiItemIndex = -1;

  set tapBangumiItemIndex(int value) {
    _tapBangumiItemIndex = value;
    notifyListeners();
  }

  int get tapBangumiItemIndex => _tapBangumiItemIndex;
  final Subgroup subgroup;
  bool _loading = false;

  bool get loading => _loading;

  SubgroupModel(this.subgroup) {
    this._loadBangumis();
  }

  List<SubgroupGallery> _galleries;

  List<SubgroupGallery> get galleries => _galleries;

  _loadBangumis() async {
    this._loading = true;
    notifyListeners();
    final Resp resp = await (this + Repo.subgroup(this.subgroup.id));
    this._loading = false;
    if (resp.success) {
      this._galleries = resp.data;
    } else {
      "加载字幕组作品年表失败：${resp.msg}".toast();
    }
    notifyListeners();
  }
}
