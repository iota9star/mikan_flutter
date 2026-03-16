import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/core/common/consts.dart';
import 'package:mikan/core/common/delegate.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/common/http_cache_manager.dart';
import 'package:mikan/core/common/kit.dart';
import 'package:mikan/core/common/log.dart';
import 'package:mikan/core/common/network_font_loader.dart';
import 'package:mikan/core/models/fonts.dart';
import 'package:mikan/core/widgets/ripple_tap.dart';
import 'package:mikan/core/widgets/scalable_tap.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';

part 'fonts.g.dart';

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
    return FontsState();
  }

  Future<void> load() async {
    try {
      final fontsData = await MikanApi.fonts();
      final fonts = fontsData
          .map((it) {
            final Font font = Font.fromJson(it);
            font.files = font.files.map((e) => '${ExtraUrl.fontsBaseUrl}/$e').toList();
            return font;
          })
          .toList()
          .cast<Font>();

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

      final newProgress = Map<String, ProgressChunkEvent>.from(state.fontProgress);
      newProgress[font.id] = ProgressChunkEvent(total: hasNull ? null : total, progress: progress, key: font.id);

      final DateTime now = DateTime.now();
      if (now.isAfter(_lastUpdate)) {
        _lastUpdate = now.add(const Duration(milliseconds: 500));
        Future.delayed(const Duration(milliseconds: 100), () {
          state = state.copyWith(fontProgress: newProgress);
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

@FFRoute(name: '/fonts')
class FontsPage extends ConsumerWidget {
  const FontsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fonts = ref.watch(fontsProvider.select((s) => s.fonts));
    final loading = ref.watch(fontsProvider.select((s) => s.loading));

    return Scaffold(
      body: EasyRefresh(
        onRefresh: () => ref.read(fontsProvider.notifier).load(),
        header: defaultHeader,
        refreshOnStart: true,
        child: CustomScrollView(
          slivers: [
            SliverPinnedAppBar(
              title: '字体管理',
              actions: [
                Tooltip(
                  message: '重置默认字体',
                  child: IconButton(
                    icon: const Icon(Icons.restart_alt_rounded),
                    onPressed: () => ref.read(fontsProvider.notifier).resetDefaultFont(),
                  ),
                ),
              ],
            ),
            if (loading && fonts.isEmpty)
              const SliverToBoxAdapter(child: Center(child: ExpressiveLoadingIndicator()))
            else if (fonts.isEmpty)
              SliverToBoxAdapter(
                child: Center(child: Text('暂无字体', style: Theme.of(context).textTheme.bodyLarge)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverWaterfallFlow(
                  gridDelegate: SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
                    minCrossAxisExtent: 250.0,
                    mainAxisSpacing: context.margins,
                    crossAxisSpacing: context.margins,
                  ),
                  delegate: SliverChildBuilderDelegate((_, index) {
                    final font = fonts[index];
                    return FontItemCard(font: font);
                  }, childCount: fonts.length),
                ),
              ),
            sliverGapH24WithNavBarHeight(context),
          ],
        ),
      ),
    );
  }
}

class FontItemCard extends ConsumerWidget {
  const FontItemCard({super.key, required this.font});

  final Font font;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final style1 = theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onTertiaryContainer);
    final style2 = theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onSecondaryContainer);

    return ScalableCard(
      onTap: () {
        ref.read(fontsProvider.notifier).enableFont(font);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    font.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const Gap(4),
                FontProgressIndicator(fontId: font.id),
              ],
            ),
            const Gap(4),
            Row(
              children: [
                RippleTap(
                  onTap: () {},
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    child: Text('${font.files.length}个字体', style: style1),
                  ),
                ),
                const Gap(4),
                RippleTap(
                  onTap: font.official.launchAppAndCopy,
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    child: Text('官网', style: style2),
                  ),
                ),
                const Gap(4),
                RippleTap(
                  onTap: font.license.url.launchAppAndCopy,
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    child: Text(font.license.name, style: style2),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Text(font.desc, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class FontProgressIndicator extends ConsumerWidget {
  const FontProgressIndicator({super.key, required this.fontId});

  final String fontId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(fontProgressProvider(fontId));
    final usedFontFamilyId = ref.watch(usedFontFamilyIdProvider);

    if (event == null) {
      return const SizedBox();
    }
    if (event.percent == 1.0) {
      if (usedFontFamilyId == fontId) {
        return const Icon(Icons.check_circle_outline_rounded);
      } else {
        return const SizedBox();
      }
    }
    return const ExpressiveLoadingIndicator(constraints: BoxConstraints.tightFor(width: 16, height: 16));
  }
}
