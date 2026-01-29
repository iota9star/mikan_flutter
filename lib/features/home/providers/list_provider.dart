import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../mikan_api.dart';
import '../../../../../shared/internal/extension.dart';
import '../../../../../shared/internal/hive.dart';
import '../../../../../shared/models/record_item.dart';

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
      final mergedRecords = currentRecords.isNotEmpty ? {...currentRecords, ...newRecords}.toList() : newRecords;

      setIfMounted(ref, AsyncValue.data(ListData(page: 1, records: mergedRecords)));
    } catch (e) {
      // Silently ignore background refresh errors - we already have cached data
    }
  }

  /// Load more records (pagination)
  Future<void> loadMore() async {
    final currentPage = state.value?.page ?? 0;
    final hasReachedEnd = state.value?.hasReachedEnd ?? false;

    if (hasReachedEnd) {
      return;
    }

    final newState = await AsyncValue.guard(() async {
      final newRecords = await MikanApi.list(currentPage + 1);
      final currentRecords = state.value?.records ?? [];
      final updatedRecords = [...currentRecords, ...newRecords];

      return ListData(page: currentPage + 1, records: updatedRecords, hasReachedEnd: newRecords.isEmpty);
    });
    setIfMounted(ref, newState);
  }

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
        final newSet = {...oldRecords, ...newRecords};
        return ListData(page: 1, records: newSet.toList());
      }

      // First load
      return ListData(page: 1, records: newRecords);
    });

    setIfMounted(ref, result);

    // Calculate update count for UI to handle
    if (result.hasValue) {
      final oldRecords = previousData.records;
      final newRecords = result.value?.records ?? [];
      final updateCount = newRecords.length - oldRecords.length;
      return RefreshResult(updateCount: updateCount, hasUpdate: updateCount > 0);
    }

    return const RefreshResult();
  }
}
