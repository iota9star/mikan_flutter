import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:kache_riverpod/kache_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/log.dart';
import 'package:mikan/core/models/announcement.dart';
import 'package:mikan/core/models/bangumi_row.dart';
import 'package:mikan/core/models/cached_list.dart';
import 'package:mikan/core/models/carousel.dart';
import 'package:mikan/core/models/index.dart' as model;
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/models/season.dart';
import 'package:mikan/core/models/user.dart';
import 'package:mikan/core/models/year_season.dart';

part 'index_provider.g.dart';

/// SWR cache query for the main [model.Index] data.
final _indexKacheProvider = kacheProvider.autoDispose<model.Index>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (_) => KacheQuery<model.Index>.persisted(
    key: KacheKey('mikan', ['index']),
    binding: KacheInit.indexBinding,
    fetch: (_) => MikanApi.index(),
    policy: KachePolicy.staleWhileRevalidate(),
  ),
);

/// SWR cache query for the OVA / day(-1, -1) record list.
final _ovaKacheProvider = kacheProvider.autoDispose<CachedRecordList>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (_) => KacheQuery<CachedRecordList>.persisted(
    key: KacheKey('mikan', ['ova']),
    binding: KacheInit.recordListBinding,
    fetch: (_) async => CachedRecordList(await MikanApi.day(-1, -1)),
    policy: KachePolicy.staleWhileRevalidate(),
  ),
);

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
  int _requestToken = 0;

  @override
  Future<IndexData> build() async {
    // Watch both kache snapshots reactively — Riverpod re-triggers build()
    // whenever either snapshot changes.
    final indexSnapshot = ref.watch(_indexKacheProvider);
    final ovaSnapshot = ref.watch(_ovaKacheProvider);

    final indexModel = indexSnapshot.dataOrNull;
    final ovaData = ovaSnapshot.dataOrNull?.items ?? const <RecordItem>[];

    // If we have cached index data, show it immediately (SWR).
    if (indexModel != null) {
      final isFromCache = indexSnapshot.source == KacheDataSource.persistence;
      return _buildIndexData(indexModel, ovaData, isFromCache: isFromCache);
    }

    // No cached data. If loading or idle, keep the Future pending so the UI
    // shows a loading spinner. The kache snapshot will update and re-trigger
    // this build via the ref.watch above.
    if (indexSnapshot.isLoading || indexSnapshot.phase == KachePhase.idle) {
      // Never completes — stays in AsyncLoading until kache produces data.
      await Completer<IndexData>().future;
    }

    // Load failed with no cached data.
    if (indexSnapshot.isFailed) {
      final cause = indexSnapshot.failure?.cause;
      if (cause is Error) {
        throw cause;
      } else if (cause is Exception) {
        throw cause;
      }
      throw Exception(cause ?? 'Index load failed');
    }

    return const IndexData();
  }

  /// Refreshes all index data from network.
  Future<IndicatorResult> refresh() async {
    final currentToken = ++_requestToken;
    final currentData = state.value;
    final preferredSeason = currentData?.selectedSeason;

    try {
      // Force refresh both kache resources in parallel.
      final indexSnapshot = await ref.read(_indexKacheProvider.notifier).refresh().timeout(const Duration(seconds: 15));
      final ovaSnapshot = await ref.read(_ovaKacheProvider.notifier).refresh().timeout(const Duration(seconds: 15));

      final indexModel = indexSnapshot.dataOrNull;
      final ovas = ovaSnapshot.dataOrNull?.items ?? const <RecordItem>[];

      if (indexModel == null) {
        return IndicatorResult.fail;
      }

      final data = _buildIndexData(indexModel, ovas);
      final result = _preservePreferredSeason(
        data,
        preferredSeason: preferredSeason,
        fallbackBangumiRows: currentData?.bangumiRows,
      );

      if (currentToken == _requestToken) {
        setIfMounted(ref, AsyncValue.data(result.data));
        _refreshPreferredSeasonRowsInBackground(result.seasonToRefresh, requestToken: currentToken);
      }
      return IndicatorResult.success;
    } catch (e, stackTrace) {
      Log.e(error: e, stackTrace: stackTrace, msg: 'index refresh failed', tag: 'IndexFlow');
      if (currentData == null) {
        setIfMounted(ref, AsyncValue.error(e, stackTrace));
      }
      return IndicatorResult.fail;
    }
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
