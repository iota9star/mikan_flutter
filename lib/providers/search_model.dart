import 'package:flutter/cupertino.dart';

import '../internal/extension.dart';
import '../internal/hive.dart';
import '../internal/repo.dart';
import '../model/search.dart';
import 'base_model.dart';

class SearchModel extends BaseModel {
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

  set subgroupId( String? value) {
    _subgroupId = _subgroupId == value ? null : value;
    _searching(keywords, subgroupId: _subgroupId);
  }

  void search(String keywords) {
    _searchResult = null;
    _keywordsController.value = TextEditingValue(
      text: keywords,
      selection: TextSelection.fromPosition(
        TextPosition(
          offset: keywords.length,
        ),
      ),
    );
    _searching(keywords);
  }

  Future<void> _searching( String? keywords, {String? subgroupId}) async {
    if (keywords.isNullOrBlank) {
      return '请输入搜索关键字'.toast();
    }
    _keywords = keywords;
    _loading = true;
    notifyListeners();
    final resp = await  Repo.search(keywords, subgroupId: subgroupId);
    if (resp.success) {
      _searchResult = resp.data;
      if (_searchResult?.records.isNotEmpty ?? false) {
        _saveNewKeywords(keywords!);
      }
    } else {
      '搜索出错啦：${resp.msg}'.toast();
    }
    _loading = false;
    notifyListeners();
  }

  void _saveNewKeywords(String keywords) {
    final List<String> history =
        MyHive.db.get(HiveDBKey.mikanSearch, defaultValue: <String>[]);
    if (history.contains(keywords)) {
      return;
    }
    history.insert(0, keywords);
    if (history.length > 8) {
      history.remove(history.last);
    }
    MyHive.db.put(HiveDBKey.mikanSearch, history);
  }
}
