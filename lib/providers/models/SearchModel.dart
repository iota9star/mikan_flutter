import 'package:mikan_flutter/core/repo.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/model/search.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';

class SearchModel extends BaseModel {
  String _keywords;

  String _subgroupId;

  Search _search;

  bool _loading = false;

  String _tapBangumiItemFlag;

  String get tapBangumiItemFlag => _tapBangumiItemFlag;

  set tapBangumiItemFlag(String value) {
    _tapBangumiItemFlag = value;
    notifyListeners();
  }

  String get keywords => _keywords;

  Search get search => _search;

  String get subgroupId => _subgroupId;

  bool get loading => _loading;

  set subgroupId(final String value) {
    this._subgroupId = value;
    notifyListeners();
    this.searching(keywords, subgroupId: this._subgroupId);
  }

  SearchModel() {
    this.searching("刀剑神域");
  }

  searching(final String keywords, {final String subgroupId}) {
    this._keywords = keywords;
    this._loading = true;
    Repo.search(keywords, subgroupId: subgroupId).then((resp) {
      if (resp.success) {
        this._search = resp.data;
      } else {
        "搜索出错啦：${resp.msg}".toast();
      }
    }).whenComplete(() {
      this._loading = false;
      notifyListeners();
    });
  }
}
