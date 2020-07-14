import 'package:mikan_flutter/core/repo.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/model/bangumi_details.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';

class BangumiDetailsModel extends BaseModel {
  final String url;

  bool _loading = false;

  bool get loading => _loading;
  BangumiDetails _bangumiDetails;

  BangumiDetails get bangumiDetails => _bangumiDetails;

  BangumiDetailsModel(this.url) {
    this.load();
  }

  void load() {
    this._loading = true;
    Repo.details(this.url).then((resp) {
      if (resp.success) {
        _bangumiDetails = resp.data;
      } else {
        resp.msg.toast();
      }
    }).whenComplete(() {
      this._loading = false;
      notifyListeners();
    });
  }
}
