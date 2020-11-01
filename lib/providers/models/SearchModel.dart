import 'package:flutter/cupertino.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/search.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';

class SearchModel extends CancelableBaseModel {
  final TextEditingController _keywordsController = TextEditingController();

  TextEditingController get keywordsController => _keywordsController;

  String _keywords;

  String _subgroupId;

  SearchResult _searchResult;

  bool _loading = false;

  String _tapBangumiItemFlag;

  String get tapBangumiItemFlag => _tapBangumiItemFlag;

  set tapBangumiItemFlag(String value) {
    _tapBangumiItemFlag = value;
    notifyListeners();
  }

  String get keywords => _keywords;

  SearchResult get searchResult => _searchResult;

  String get subgroupId => _subgroupId;

  bool get loading => _loading;

  set subgroupId(final String value) {
    this._subgroupId = this._subgroupId == value ? null : value;
    this._searchResult?.bangumis = null;
    this._searchResult?.searchs = null;
    notifyListeners();
    this.search(keywords, subgroupId: this._subgroupId);
  }

  search(final String keywords, {final String subgroupId}) async {
    this._keywords = keywords;
    this._loading = true;
    final resp = await (this + Repo.search(keywords, subgroupId: subgroupId));
    if (resp.success) {
      this._searchResult = resp.data;
    } else {
      "搜索出错啦：${resp.msg}".toast();
    }
    this._loading = false;
    notifyListeners();
  }
}
