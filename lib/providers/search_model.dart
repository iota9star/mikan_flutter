import 'package:flutter/cupertino.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/search.dart';
import 'package:mikan_flutter/providers/base_model.dart';

class SearchModel extends CancelableBaseModel {
  final TextEditingController _keywordsController = TextEditingController();

  TextEditingController get keywordsController => _keywordsController;

  String? _keywords;

  String? _subgroupId;

  SearchResult? _searchResult;

  bool _loading = false;

  String? get keywords => _keywords;

  SearchResult? get searchResult => _searchResult;

  String? get subgroupId => _subgroupId;

  bool get loading => _loading;

  set subgroupId(final String? value) {
    _subgroupId = _subgroupId == value ? null : value;
    _searching(keywords, subgroupId: _subgroupId);
  }

  search(final String keywords) {
    _searchResult = null;
    _keywordsController.value = TextEditingValue(
      text: keywords,
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: keywords.length,
        ),
      ),
    );
    _searching(keywords);
  }

  _searching(final String? keywords, {final String? subgroupId}) async {
    if (keywords.isNullOrBlank) {
      return "请输入搜索关键字".toast();
    }
    _keywords = keywords;
    _loading = true;
    notifyListeners();
    final resp = await (this + Repo.search(keywords, subgroupId: subgroupId));
    if (resp.success) {
      _searchResult = resp.data;
      if (_searchResult?.records.isNotEmpty == true) {
        _saveNewKeywords(keywords!);
      }
    } else {
      "搜索出错啦：${resp.msg}".toast();
    }
    _loading = false;
    notifyListeners();
  }

  void _saveNewKeywords(String keywords) {
    final List<String> history =
        MyHive.db.get(HiveDBKey.mikanSearch, defaultValue: <String>[]);
    if (history.contains(keywords)) return;
    history.insert(0, keywords);
    if (history.length > 8) {
      history.remove(history.last);
    }
    MyHive.db.put(HiveDBKey.mikanSearch, history);
  }
}
