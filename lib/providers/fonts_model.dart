import 'dart:async';

import 'package:mikan_flutter/internal/consts.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/http_cache_manager.dart';
import 'package:mikan_flutter/internal/network_font_loader.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/fonts.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:mikan_flutter/providers/theme_model.dart';

class FontsModel extends CancelableBaseModel {
  bool _loading = true;

  List<Font> _fonts = [];

  String? _lastEnableFont;

  List<Font> get fonts => _fonts;

  bool get loading => _loading;

  ThemeModel _themeModel;

  String? get enableFontFamily => this._themeModel.themeItem.fontFamily;

  late DateTime _lastUpdate;

  final Map<String, ProgressChunkEvent> fontProgress =
      <String, ProgressChunkEvent>{};
  final Map<String, Cancelable> _loadingTask = <String, Cancelable>{};

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
      final String? fontFamily = this._themeModel.themeItem.fontFamily;
      if (fontFamily.isNotBlank) {
        final Font font = this._fonts.firstWhere((it) => it.id == fontFamily);
        this.enableFont(font);
      }
    } else {
      "获取字体列表失败：${resp.msg}".toast();
    }
    notifyListeners();
  }

  Future<void> enableFont(Font font) async {
    this._lastEnableFont = font.id;
    if (_loadingTask.containsKey(font.id)) {
      return;
    }
    final StreamController<Iterable<ProgressChunkEvent>> chunkEvents =
        StreamController<Iterable<ProgressChunkEvent>>();
    _lastUpdate = DateTime.now();
    _loadingTask[font.id] = Cancelable();
    chunkEvents.stream.listen((event) {
      int total = 0;
      int progress = 0;
      bool hasNull = false;
      for (final value in event) {
        if (value.total == null) {
          hasNull = true;
        }
        total += value.total ?? 0;
        progress += value.progress;
      }
      fontProgress[font.id] = ProgressChunkEvent(
        total: hasNull ? null : total,
        progress: progress,
        key: font.id,
      );
      final DateTime now = DateTime.now();
      if (now.isAfter(_lastUpdate)) {
        _lastUpdate = now.add(Duration(milliseconds: 500));
        Future.delayed(Duration(milliseconds: 100), () {
          notifyListeners();
        });
      }
    });
    try {
      await NetworkFontLoader.load(
        font.id,
        font.files,
        chunkEvents: chunkEvents,
        cancelable: _loadingTask[font.id],
      );
      if (_lastEnableFont == font.id) {
        this._themeModel.applyFont(font);
      }
    } catch (e) {
      e.debug();
    } finally {
      chunkEvents.close();
      _loadingTask.remove(font.id)?.cancel("on finally.....");
    }
  }

  @override
  void dispose() {
    _loadingTask.values
        .forEach((cancelable) => cancelable.cancel("on disposed..."));
    _loadingTask.clear();
    super.dispose();
  }

  void resetDefaultFont() {
    this._themeModel.applyFont(null);
  }
}
