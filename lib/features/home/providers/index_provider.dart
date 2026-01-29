import 'dart:async';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../mikan_api.dart';
import '../../../../../shared/internal/extension.dart';
import '../../../../../shared/internal/hive.dart';
import '../../../../../shared/models/announcement.dart';
import '../../../../../shared/models/bangumi_row.dart';
import '../../../../../shared/models/carousel.dart';
import '../../../../../shared/models/index.dart' as model;
import '../../../../../shared/models/record_item.dart';
import '../../../../../shared/models/season.dart';
import '../../../../../shared/models/user.dart';
import '../../../../../shared/models/year_season.dart';

part 'index_provider.g.dart';

class IndexData {
  const IndexData({
    this.years = const [],
    this.bangumiRows = const [],
    this.ovas = const [],
    this.carousels = const [],
    this.selectedSeason,
    this.user,
    this.announcements,
    this.selectedBangumiRow,
    this.isFromCache = false,
  });

  final List<YearSeason> years;
  final List<BangumiRow> bangumiRows;
  final List<RecordItem> ovas;
  final List<Carousel> carousels;
  final Season? selectedSeason;
  final User? user;
  final List<Announcement>? announcements;
  final BangumiRow? selectedBangumiRow;

  /// Indicates if this data is from cache (not fresh from network).
  final bool isFromCache;

  IndexData copyWith({
    List<YearSeason>? years,
    List<BangumiRow>? bangumiRows,
    List<RecordItem>? ovas,
    List<Carousel>? carousels,
    Season? selectedSeason,
    User? user,
    List<Announcement>? announcements,
    BangumiRow? selectedBangumiRow,
    bool? isFromCache,
  }) {
    return IndexData(
      years: years ?? this.years,
      bangumiRows: bangumiRows ?? this.bangumiRows,
      ovas: ovas ?? this.ovas,
      carousels: carousels ?? this.carousels,
      selectedSeason: selectedSeason ?? this.selectedSeason,
      user: user ?? this.user,
      announcements: announcements ?? this.announcements,
      selectedBangumiRow: selectedBangumiRow ?? this.selectedBangumiRow,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

@riverpod
class Index extends _$Index {
  int _requestToken = 0;

  @override
  Future<IndexData> build() async {
    // First, try to load from cache for instant UI
    final cachedIndex = MyHive.getIndexCache();
    final cachedOvas = MyHive.getOvaCache();

    if (cachedIndex != null) {
      final cachedData = _buildIndexData(cachedIndex, cachedOvas ?? [], isFromCache: true);
      // Set cached data immediately
      state = AsyncValue.data(cachedData);

      // Then fetch fresh data in background
      unawaited(_loadFreshDataInBackground());
      return cachedData;
    }

    // No cache, load from network
    final results = await Future.wait([_loadIndex(), _loadOVA()]);
    return results[0];
  }

  /// Loads fresh data in background and updates state.
  Future<void> _loadFreshDataInBackground() async {
    try {
      final results = await Future.wait([_loadIndex(saveToCache: true), _loadOVA(saveToCache: true)]);
      setIfMounted(ref, AsyncValue.data(results[0].copyWith(isFromCache: false)));
    } catch (e) {
      // Silently ignore background refresh errors - we already have cached data
    }
  }

  /// Selects a bangumi row for display.
  void selectBangumiRow(BangumiRow? value) {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(selectedBangumiRow: value));
    }
  }

  /// Refreshes all index data.
  Future<void> refresh() async {
    final newState = await AsyncValue.guard(() async {
      final results = await Future.wait([_loadIndex(saveToCache: true), _loadOVA(saveToCache: true)]);
      return results[0].copyWith(isFromCache: false);
    });
    setIfMounted(ref, newState);
  }

  /// Selects a specific season and loads its data.
  Future<void> selectSeason(Season season) async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    final currentToken = ++_requestToken;

    state = const AsyncValue.loading();

    final newState = await AsyncValue.guard(() async {
      final bangumiRows = await MikanApi.season(season.year, season.season);

      if (currentToken != _requestToken) {
        throw StateError('Request cancelled by newer request');
      }

      final latestState = state.value ?? currentState;
      return latestState.copyWith(selectedSeason: season, bangumiRows: bangumiRows);
    });

    if (currentToken == _requestToken) {
      setIfMounted(ref, newState);
    }
  }

  Future<IndexData> _loadIndex({bool saveToCache = false}) async {
    final index = await MikanApi.index();
    final currentData = state.value ?? const IndexData();

    // Save to cache if requested
    if (saveToCache) {
      unawaited(MyHive.saveIndexCache(index));
    }

    return _buildIndexData(index, currentData.ovas);
  }

  Future<IndexData> _loadOVA({bool saveToCache = false}) async {
    final data = await MikanApi.day(-1, -1);
    final currentData = state.value ?? const IndexData();

    // Save to cache if requested
    if (saveToCache) {
      unawaited(MyHive.saveOvaCache(data));
    }

    return currentData.copyWith(ovas: data);
  }

  IndexData _buildIndexData(model.Index? index, List<RecordItem> ovas, {bool isFromCache = false}) {
    if (index == null) {
      return IndexData(ovas: ovas, isFromCache: isFromCache);
    }

    Season? selectedSeason;
    if (!index.years.isNullOrEmpty) {
      for (final year in index.years) {
        selectedSeason = year.seasons.firstWhereOrNull((element) => element.active);
        if (selectedSeason != null) {
          break;
        }
      }
    }

    selectedSeason ??= index.years.firstOrNull?.seasons.firstOrNull;

    return IndexData(
      years: index.years,
      bangumiRows: index.bangumiRows,
      selectedBangumiRow: index.bangumiRows.firstOrNull,
      carousels: index.carousels,
      user: index.user,
      announcements: index.announcements,
      selectedSeason: selectedSeason,
      ovas: ovas,
      isFromCache: isFromCache,
    );
  }
}

@riverpod
Season? selectedSeason(Ref ref) {
  return ref.watch(indexProvider).value?.selectedSeason;
}

@riverpod
List<YearSeason> years(Ref ref) {
  return ref.watch(indexProvider).value?.years ?? [];
}
