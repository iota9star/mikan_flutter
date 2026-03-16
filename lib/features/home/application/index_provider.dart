import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/common/log.dart';
import 'package:mikan/core/models/announcement.dart';
import 'package:mikan/core/models/bangumi_row.dart';
import 'package:mikan/core/models/carousel.dart';
import 'package:mikan/core/models/index.dart' as model;
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/models/season.dart';
import 'package:mikan/core/models/user.dart';
import 'package:mikan/core/models/year_season.dart';

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
    this.isFromCache = false,
  });

  final List<YearSeason> years;
  final List<BangumiRow> bangumiRows;
  final List<RecordItem> ovas;
  final List<Carousel> carousels;
  final Season? selectedSeason;
  final User? user;
  final List<Announcement>? announcements;

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
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

@riverpod
class Index extends _$Index {
  static const _refreshTimeout = Duration(seconds: 15);

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
    return _loadMergedData(saveToCache: true);
  }

  /// Loads fresh data in background and updates state.
  Future<void> _loadFreshDataInBackground() async {
    final currentToken = ++_requestToken;
    final currentData = state.value;
    final preferredSeason = currentData?.selectedSeason;

    try {
      final data = await _loadMergedData(saveToCache: true);
      final result = _preservePreferredSeason(
        data,
        preferredSeason: preferredSeason,
        fallbackBangumiRows: currentData?.bangumiRows,
      );
      if (currentToken == _requestToken) {
        setIfMounted(ref, AsyncValue.data(result.data));
        _refreshPreferredSeasonRowsInBackground(result.seasonToRefresh, requestToken: currentToken);
      }
    } catch (e, stackTrace) {
      Log.e(error: e, stackTrace: stackTrace, msg: 'index background refresh failed', tag: 'IndexFlow');
      // Silently ignore background refresh errors - we already have cached data
    }
  }

  /// Refreshes all index data.
  Future<IndicatorResult> refresh() async {
    final currentToken = ++_requestToken;
    final currentData = state.value;
    final preferredSeason = currentData?.selectedSeason;

    final newState = await AsyncValue.guard(() async {
      final data = await _loadMergedData(saveToCache: true).timeout(_refreshTimeout);
      return _preservePreferredSeason(
        data,
        preferredSeason: preferredSeason,
        fallbackBangumiRows: currentData?.bangumiRows,
      );
    });

    if (currentToken == _requestToken) {
      if (newState.hasValue) {
        final result = newState.requireValue;
        setIfMounted(ref, AsyncValue.data(result.data));
        _refreshPreferredSeasonRowsInBackground(result.seasonToRefresh, requestToken: currentToken);
        return IndicatorResult.success;
      }

      if (currentData == null) {
        setIfMounted(ref, AsyncValue.error(newState.error!, newState.stackTrace!));
      }
      Log.e(error: newState.error, stackTrace: newState.stackTrace, msg: 'index refresh failed', tag: 'IndexFlow');

      return IndicatorResult.fail;
    }

    return IndicatorResult.fail;
  }

  /// Selects a specific season and loads its data.
  Future<void> selectSeason(Season season) async {
    final currentState = state.value;
    if (currentState == null) {
      return;
    }

    final currentToken = ++_requestToken;
    state = AsyncValue.data(currentState.copyWith(selectedSeason: season));

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

  Future<IndexData> _loadMergedData({required bool saveToCache}) async {
    final indexData = await _loadIndex(saveToCache: saveToCache);
    final ovaData = await _loadOVA(saveToCache: saveToCache);
    return _mergeIndexData(indexData, ovaData, isFromCache: false);
  }

  IndexData _mergeIndexData(IndexData indexData, IndexData ovaData, {bool? isFromCache}) {
    return indexData.copyWith(ovas: ovaData.ovas, isFromCache: isFromCache ?? indexData.isFromCache);
  }

  _PreservedSeasonResult _preservePreferredSeason(
    IndexData data, {
    Season? preferredSeason,
    List<BangumiRow>? fallbackBangumiRows,
  }) {
    final matchedSeason = _findMatchingSeason(data.years, preferredSeason);
    if (matchedSeason == null || _isSameSeason(matchedSeason, data.selectedSeason)) {
      return _PreservedSeasonResult(data: data);
    }

    return _PreservedSeasonResult(
      data: data.copyWith(selectedSeason: matchedSeason, bangumiRows: fallbackBangumiRows ?? data.bangumiRows),
      seasonToRefresh: matchedSeason,
    );
  }

  Season? _findMatchingSeason(List<YearSeason> years, Season? preferredSeason) {
    if (preferredSeason == null) {
      return null;
    }

    for (final year in years) {
      for (final season in year.seasons) {
        if (_isSameSeason(season, preferredSeason)) {
          return season;
        }
      }
    }

    return null;
  }

  bool _isSameSeason(Season? a, Season? b) {
    return a != null && b != null && a.year == b.year && a.season == b.season;
  }

  void _refreshPreferredSeasonRowsInBackground(Season? season, {required int requestToken}) {
    if (season == null) {
      return;
    }

    unawaited(() async {
      try {
        final bangumiRows = await MikanApi.season(season.year, season.season);
        if (!ref.mounted || requestToken != _requestToken) {
          return;
        }

        final currentData = state.value;
        if (currentData == null || !_isSameSeason(currentData.selectedSeason, season)) {
          return;
        }

        state = AsyncValue.data(currentData.copyWith(bangumiRows: bangumiRows));
      } catch (_) {
        // Keep current rows if the seasonal refresh fails. Main index data has already been refreshed.
      }
    }());
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

class _PreservedSeasonResult {
  const _PreservedSeasonResult({required this.data, this.seasonToRefresh});

  final IndexData data;
  final Season? seasonToRefresh;
}
