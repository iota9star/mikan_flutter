import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache_riverpod/kache_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
import 'package:mikan/core/common/consts.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/common/http_cache_manager.dart';
import 'package:mikan/core/common/log.dart';
import 'package:mikan/core/common/network_font_loader.dart';
import 'package:mikan/core/models/cached_list.dart';
import 'package:mikan/core/models/fonts.dart';

part 'fonts_provider.g.dart';

/// Persisted SWR cache for the font list. Fonts change rarely so this is a
/// strong cache candidate.
final fontsListKacheProvider = kacheProvider.autoDispose<CachedFontList>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (_) => KacheQuery<CachedFontList>.persisted(
    key: KacheKey('mikan', ['fonts']),
    binding: KacheInit.fontListBinding,
    fetch: (_) async {
      final fontsData = await MikanApi.fonts();
      final fonts = fontsData
          .map((it) {
            final Font font = Font.fromJson(it);
            font.files = font.files.map((e) => '${ExtraUrl.fontsBaseUrl}/$e').toList();
            return font;
          })
          .toList()
          .cast<Font>();
      return CachedFontList(fonts);
    },
    policy: KachePolicy.staleWhileRevalidate(),
  ),
);

class FontsState {
  FontsState({
    this.selectedFont,
    this.fonts = const [],
    this.loading = true,
    this.fontProgress = const {},
    this.usedFontFamilyId,
  });

  static const Object _sentinel = Object();

  final Font? selectedFont;
  final List<Font> fonts;
  final bool loading;
  final Map<String, ProgressChunkEvent> fontProgress;
  final String? usedFontFamilyId;

  FontsState copyWith({
    Object? selectedFont = _sentinel,
    List<Font>? fonts,
    bool? loading,
    Map<String, ProgressChunkEvent>? fontProgress,
    Object? usedFontFamilyId = _sentinel,
  }) {
    return FontsState(
      selectedFont: identical(selectedFont, _sentinel) ? this.selectedFont : selectedFont as Font?,
      fonts: fonts ?? this.fonts,
      loading: loading ?? this.loading,
      fontProgress: fontProgress ?? this.fontProgress,
      usedFontFamilyId: identical(usedFontFamilyId, _sentinel) ? this.usedFontFamilyId : usedFontFamilyId as String?,
    );
  }
}

@riverpod
class Fonts extends _$Fonts {
  String? _lastEnableFont;
  final Map<String, Cancelable> _loadingTask = {};
  late DateTime _lastUpdate;

  @override
  FontsState build() {
    _lastUpdate = DateTime.now();
    ref.onDispose(() {
      for (final task in _loadingTask.values) {
        task.cancel('provider disposed');
      }
      _loadingTask.clear();
    });
    return FontsState();
  }

  Future<void> load() async {
    try {
      // Read from kache SWR cache — instant load from persistence, then
      // background refresh from network.
      final snapshot = await ref.read(fontsListKacheProvider.notifier).refresh();
      final fonts = snapshot.dataOrNull?.items ?? const <Font>[];

      final usedFontFamilyId = MyHive.getFontFamily()?.value;
      state = state.copyWith(fonts: fonts, loading: false, usedFontFamilyId: usedFontFamilyId);

      if (usedFontFamilyId.isNotBlank) {
        final font = fonts.firstWhereOrNull((it) => it.id == usedFontFamilyId);
        if (font != null) {
          await enableFont(font);
        }
      }
    } catch (e, s) {
      e.$error(stackTrace: s);
      state = state.copyWith(loading: false);
      '字体列表加载失败'.toast();
    }
  }

  Future<void> enableFont(Font font) async {
    _lastEnableFont = font.id;
    if (_loadingTask.containsKey(font.id)) {
      return;
    }
    final chunkEvents = StreamController<Iterable<ProgressChunkEvent>>();
    _lastUpdate = DateTime.now().subtract(const Duration(seconds: 1));
    _loadingTask[font.id] = Cancelable();

    final subscription = chunkEvents.stream.listen((event) {
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

      final newProgress = Map<String, ProgressChunkEvent>.from(state.fontProgress);
      newProgress[font.id] = ProgressChunkEvent(total: hasNull ? null : total, progress: progress, key: font.id);

      final DateTime now = DateTime.now();
      if (now.isAfter(_lastUpdate)) {
        _lastUpdate = now.add(const Duration(milliseconds: 500));
        Future.delayed(const Duration(milliseconds: 100), () {
          if (ref.mounted) {
            state = state.copyWith(fontProgress: newProgress);
          }
        });
      }
    });

    try {
      await NetworkFontLoader.load(font.id, font.files, chunkEvents: chunkEvents, cancelable: _loadingTask[font.id]);
      if (_lastEnableFont == font.id) {
        await MyHive.setFontFamily(MapEntry(font.name, font.id));
        state = state.copyWith(selectedFont: font, usedFontFamilyId: font.id);
      }
    } catch (e, s) {
      e.$error(stackTrace: s);
    } finally {
      await subscription.cancel();
      await chunkEvents.close();
      await _loadingTask.remove(font.id)?.cancel('on finally.....');
    }
  }

  void resetDefaultFont() {
    _lastEnableFont = null;
    MyHive.setFontFamily(null);
    state = state.copyWith(selectedFont: null, usedFontFamilyId: null);
  }
}

@riverpod
ProgressChunkEvent? fontProgress(Ref ref, String fontId) {
  return ref.watch(fontsProvider.select((s) => s.fontProgress[fontId]));
}

@riverpod
String? usedFontFamilyId(Ref ref) {
  return ref.watch(fontsProvider.select((s) => s.usedFontFamilyId));
}
