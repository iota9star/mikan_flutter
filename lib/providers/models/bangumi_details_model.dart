import 'package:mikan_flutter/core/repo.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/model/bangumi_home.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';

class BangumiHomeModel extends BaseModel {
  final String id;

  bool _loading = false;

  bool get loading => _loading;
  BangumiHome _bangumiHome;

  BangumiHome get bangumiHome => _bangumiHome;

  BangumiHomeModel(this.id) {
    this.load();
  }

  void load() {
    this._loading = true;
    Repo.bangumi(this.id).then((resp) {
      if (resp.success) {
        _bangumiHome = resp.data;
      } else {
        resp.msg.toast();
      }
    }).whenComplete(() {
      this._loading = false;
      notifyListeners();
    });
  }
}
