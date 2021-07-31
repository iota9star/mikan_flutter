import 'package:mikan_flutter/internal/consts.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/fonts.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/fonts.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:mikan_flutter/providers/theme_model.dart';

class FontsModel extends CancelableBaseModel {
  bool _loading = true;

  List<Font> _fonts = [];

  List<Font> get fonts => _fonts;

  bool get loading => _loading;

  ThemeModel _themeModel;

  FontsModel(this._themeModel) {
    this._load();
  }

  _load() async {
    final Resp resp = await (this + Repo.fonts());
    this._loading = false;
    if (resp.success) {
      this._fonts = resp.data
          .map((it) {
            final Font font = Font.fromJson(it);
            font.files =
                font.files.map((e) => Extra.FONTS_BASE_URL + "/" + e).toList();
            return font;
          })
          .toList()
          .cast<Font>();
    } else {
      "获取字体列表失败：${resp.msg}".toast();
    }
    notifyListeners();
  }

  enableFont(Font font) async {
    try {
      await FontManager.load(font.id, font.files);
      this._themeModel.applyFont(font.id);
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
}
