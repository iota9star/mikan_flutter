import 'package:dio/dio.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/model/theme_item.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:mikan_flutter/providers/theme_model.dart';

class ThemeEditModel extends BaseModel {
  final ThemeModel _themeModel;
  late ThemeItem _themeItem;

  ThemeItem get themeItem => _themeItem;

  ThemeEditModel(ThemeItem? themeItem, this._themeModel) {
    this._themeItem = themeItem ?? ThemeItem()
      ..id = DateTime.now().microsecondsSinceEpoch
      ..canDelete = true
      ..autoMode = true
      ..isDark = false
      ..primaryColor = this._themeModel.themeItem.primaryColor
      ..accentColor = this._themeModel.themeItem.accentColor
      ..lightBackgroundColor = this._themeModel.themeItem.lightBackgroundColor
      ..lightScaffoldBackgroundColor =
          this._themeModel.themeItem.lightScaffoldBackgroundColor
      ..darkBackgroundColor = this._themeModel.themeItem.darkBackgroundColor
      ..darkScaffoldBackgroundColor =
          this._themeModel.themeItem.darkScaffoldBackgroundColor
      ..fontFamily = this._themeModel.themeItem.fontFamily;
  }

  apply(final bool isAdd, final VoidCallback afterApply) {
    if (isAdd) {
      MyHive.themeItemBox.add(this._themeItem);
    } else {
      this._themeItem.save();
    }
    if (this._themeModel.themeItem.id == this._themeItem.id) {
      this._themeModel.themeItem = this._themeItem;
    }
    afterApply.call();
  }
}
