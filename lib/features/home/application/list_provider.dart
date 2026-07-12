import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/models/record_item.dart';

part 'list_provider.g.dart';

/// Result of refresh operation
class RefreshResult {
  const RefreshResult({this.updateCount = 0, this.hasUpdate = false});

  final int updateCount;
  final bool hasUpdate;
}

/// Immutable data class for list state
class ListData {
  const ListData({this.page = 0, this.records = const [], this.hasReachedEnd = false, this.isFromCache = false});

  final int page;
  final List<RecordItem> records;
  final bool hasReachedEnd;

  /// Indicates if this data is from cache (not fresh from network).
  final bool isFromCache;

  ListData copyWith({int? page, List<RecordItem>? records, bool? hasReachedEnd, bool? isFromCache}) {
    return ListData(
      page: page ?? this.page,
      records: records ?? this.records,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

@riverpod
class ListNotifier extends _$ListNotifier {
  @override
  Future<ListData> build() async {
    // First, try to load from cache for instant UI
    final cachedRecords = MyHive.getListCache();

    if (cachedRecords != null && cachedRecords.isNotEmpty) {
      final cachedData = ListData(page: 1, records: cachedRecords, isFromCache: true);
      // Schedule background refresh after returning cached data
      unawaited(Future.microtask(_loadFreshDataInBackground));
      return cachedData;
    }

    // No cache, load from network
    final newRecords = await MikanApi.list();
    unawaited(MyHive.saveListCache(newRecords));
    return ListData(page: 1, records: newRecords);
  }

  /// Loads fresh data in background and updates state.
  Future<void> _loadFreshDataInBackground() async {
    try {
      final newRecords = await MikanApi.list();
      // Save to cache
      unawaited(MyHive.saveListCache(newRecords));

      final currentRecords = state.value?.records ?? [];
      // Merge with existing records if we had cached data
      final mergedRecords = currentRecords.isNotEmpty ? _mergeRecords(newRecords, currentRecords) : newRecords;

      setIfMounted(ref, AsyncValue.data(ListData(page: 1, records: mergedRecords)));
    } catch (e) {
      // Silently ignore background refresh errors - we already have cached data
    }
  }

  /// Load more records (pagination)
  Future<IndicatorResult> loadMore() async {
    final currentPage = state.value?.page ?? 0;
    final hasReachedEnd = state.value?.hasReachedEnd ?? false;

    if (hasReachedEnd) {
      return IndicatorResult.noMore;
    }

    // Guard against concurrent loadMore triggers (fast scroll).
    if (_isLoadingMore) {
      return IndicatorResult.none;
    }
    _isLoadingMore = true;

    try {
      final newState = await AsyncValue.guard(() async {
        final newRecords = await MikanApi.list(currentPage + 1);
        final currentRecords = state.value?.records ?? [];
        final updatedRecords = [...currentRecords, ...newRecords];

        return ListData(page: currentPage + 1, records: updatedRecords, hasReachedEnd: newRecords.isEmpty);
      });
      setIfMounted(ref, newState);

      return newState.hasError
          ? IndicatorResult.fail
          : (newState.requireValue.hasReachedEnd ? IndicatorResult.noMore : IndicatorResult.success);
    } finally {
      _isLoadingMore = false;
    }
  }

  bool _isLoadingMore = false;

  /// Refresh and reset to first page
  Future<RefreshResult> refresh() async {
    // Keep previous data visible while loading
    final previousData = state.value ?? const ListData();

    final result = await AsyncValue.guard(() async {
      final newRecords = await MikanApi.list();
      final oldRecords = previousData.records;

      // Save to cache
      unawaited(MyHive.saveListCache(newRecords));

      // Check for updates if we had previous records
      if (oldRecords.isNotEmpty) {
        return ListData(page: 1, records: _mergeRecords(newRecords, oldRecords));
      }

      // First load
      return ListData(page: 1, records: newRecords);
    });

    setIfMounted(ref, result);

    // Calculate update count for UI to handle
    if (result.hasValue) {
      final oldRecords = previousData.records;
      final newRecords = result.value?.records ?? [];
      final oldSet = oldRecords.toSet();
      final updateCount = newRecords.where((record) => !oldSet.contains(record)).length;
      return RefreshResult(updateCount: updateCount, hasUpdate: updateCount > 0);
    }

    return const RefreshResult();
  }

  List<RecordItem> _mergeRecords(List<RecordItem> freshRecords, List<RecordItem> existingRecords) {
    // Fresh data takes priority on duplicate URLs. Set-spread keeps the *existing*
    // object for equal elements, which would discard fresh metadata updates, so we
    // prefer fresh records explicitly and only keep existing records whose URL is
    // absent from the fresh set.
    final freshUrls = {for (final r in freshRecords) r.url};
    return [...freshRecords, ...existingRecords.where((r) => !freshUrls.contains(r.url))];
  }
}
