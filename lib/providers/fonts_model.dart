import 'dart:async';

import 'package:collection/collection.dart';

import '../internal/consts.dart';
import '../internal/extension.dart';
import '../internal/hive.dart';
import '../internal/http_cache_manager.dart';
import '../internal/log.dart';
import '../internal/network_font_loader.dart';
import '../internal/repo.dart';
import '../model/fonts.dart';
import 'base_model.dart';

class FontsModel extends BaseModel {
  FontsModel() {
    _load();
  }

  bool _loading = true;

  List<Font> _fonts = [];

  String? _lastEnableFont;

  List<Font> get fonts => _fonts;

  bool get loading => _loading;

  String? get usedFontFamilyId => MyHive.getFontFamily()?.value;

  late DateTime _lastUpdate;

  final Map<String, ProgressChunkEvent> fontProgress =
      <String, ProgressChunkEvent>{};
  final Map<String, Cancelable> _loadingTask = <String, Cancelable>{};

  Future<void> _load() async {
    final resp = await Repo.fonts();
    _loading = false;
    if (resp.success) {
      _fonts = resp.data
          .map((it) {
            final Font font = Font.fromJson(it);
            font.files =
                font.files.map((e) => '${ExtraUrl.fontsBaseUrl}/$e').toList();
            return font;
          })
          .toList()
          .cast<Font>();
      if (usedFontFamilyId.isNotBlank) {
        final font = _fonts.firstWhereOrNull((it) => it.id == usedFontFamilyId);
        if (font != null) {
          await enableFont(font);
        }
      }
    } else {
      '获取字体列表失败 ${resp.msg ?? ''}'.toast();
    }
    notifyListeners();
  }

  Future<void> enableFont(Font font) async {
    _lastEnableFont = font.id;
    if (_loadingTask.containsKey(font.id)) {
      return;
    }
    final chunkEvents = StreamController<Iterable<ProgressChunkEvent>>();
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
        _lastUpdate = now.add(const Duration(milliseconds: 500));
        Future.delayed(const Duration(milliseconds: 100), notifyListeners);
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
        await MyHive.setFontFamily(MapEntry(font.name, font.id));
      }
    } catch (e, s) {
      e.$error(stackTrace: s);
    } finally {
      await chunkEvents.close();
      await _loadingTask.remove(font.id)?.cancel('on finally.....');
    }
  }

  @override
  Future<void> dispose() async {
    for (final Cancelable cancelable in _loadingTask.values) {
      await cancelable.cancel('on disposed...');
    }
    _loadingTask.clear();
    super.dispose();
  }

  void resetDefaultFont() {
    _lastEnableFont = null;
    MyHive.setFontFamily(null);
  }
}
