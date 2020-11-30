import 'package:mikan_flutter/model/theme_item.dart';
import 'package:mikan_flutter/providers/view_models/base_model.dart';
import 'package:mikan_flutter/providers/view_models/theme_list_model.dart';
import 'package:mikan_flutter/providers/view_models/theme_model.dart';

class ThemeFactoryModel extends BaseModel {
  final ThemeListModel _themeListModel;
  final ThemeModel _themeModel;
  ThemeItem _themeItem;

  ThemeItem get themeItem => _themeItem;

  ThemeFactoryModel(this._themeItem, this._themeModel, this._themeListModel) {
    this._themeItem = this._themeItem ?? this._themeModel.themeItem
      ..id = DateTime.now().microsecondsSinceEpoch;
  }

  apply() {}
}
