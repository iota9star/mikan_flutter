import 'dart:ui';

import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/model/theme_item.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:mikan_flutter/providers/theme_model.dart';

class ThemeEditModel extends BaseModel {
  final ThemeModel _themeModel;
  late ThemeItem _themeItem;

  ThemeItem get themeItem => _themeItem;

  ThemeEditModel(ThemeItem? themeItem, this._themeModel) {
    _themeItem = themeItem ?? ThemeItem()
      ..id = DateTime.now().microsecondsSinceEpoch
      ..canDelete = true
      ..autoMode = true
      ..isDark = false
      ..primaryColor = _themeModel.themeItem.primaryColor
      ..accentColor = _themeModel.themeItem.accentColor
      ..lightBackgroundColor = _themeModel.themeItem.lightBackgroundColor
      ..lightScaffoldBackgroundColor =
          _themeModel.themeItem.lightScaffoldBackgroundColor
      ..darkBackgroundColor = _themeModel.themeItem.darkBackgroundColor
      ..darkScaffoldBackgroundColor =
          _themeModel.themeItem.darkScaffoldBackgroundColor
      ..fontFamily = _themeModel.themeItem.fontFamily;
  }

  apply(final bool isAdd, final VoidCallback afterApply) {
    isAdd.debug();
    if (isAdd) {
      MyHive.themeItemBox.add(_themeItem);
    } else {
      _themeItem.save();
    }
    if (_themeModel.themeItem.id == _themeItem.id) {
      _themeModel.themeItem = _themeItem;
    }
    afterApply.call();
  }
}
