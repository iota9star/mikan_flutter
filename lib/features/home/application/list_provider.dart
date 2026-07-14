import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:kache_riverpod/kache_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/cache/kache_init.dart';
import 'package:mikan/core/cache/kache_providers.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/models/record_item.dart';

part 'list_provider.g.dart';

/// SWR cache query for the main list (page 1) record list.
final _listKacheProvider = kacheProvider.autoDispose<List<RecordItem>>(
  client: (ref) => ref.watch(kacheClientProvider),
  query: (_) => KacheQuery<List<RecordItem>>.persisted(
    key: KacheKey('mikan', ['list']),
    binding: KacheInit.recordListBinding,
    fetch: (_) => MikanApi.list(),
    policy: KachePolicy.staleWhileRevalidate(retainDataOnError: true),
  ),
);

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
  bool _isLoadingMore = false;

  @override
  Future<ListData> build() async {
    // Watch the kache snapshot reactively — SWR gives us cached data first,
    // then background-refreshes from network.
    final snapshot = ref.watch(_listKacheProvider);
    final cachedRecords = snapshot.dataOrNull;

    if (cachedRecords != null && cachedRecords.isNotEmpty) {
      final isFromCache = snapshot.source == KacheDataSource.persistence;
      return ListData(page: 1, records: cachedRecords, isFromCache: isFromCache);
    }

    // No cached data yet — if loading, return empty for now.
    if (snapshot.isLoading) {
      return const ListData();
    }

    // Load failed with no cached data.
    if (snapshot.isFailed) {
      throw snapshot.failure?.cause ?? StateError('List load failed');
    }

    return const ListData();
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

  /// Refresh and reset to first page
  Future<RefreshResult> refresh() async {
    // Keep previous data visible while loading
    final previousData = state.value ?? const ListData();

    try {
      final snapshot = await ref.read(_listKacheProvider.notifier).refresh();
      final newRecords = snapshot.dataOrNull ?? [];

      // Merge with previous records to preserve scroll context.
      if (previousData.records.isNotEmpty) {
        final merged = _mergeRecords(newRecords, previousData.records);
        setIfMounted(ref, AsyncValue.data(ListData(page: 1, records: merged)));
      } else {
        setIfMounted(ref, AsyncValue.data(ListData(page: 1, records: newRecords)));
      }

      // Calculate update count for UI to handle
      final oldRecords = previousData.records;
      final oldSet = oldRecords.toSet();
      final updateCount = newRecords.where((record) => !oldSet.contains(record)).length;
      return RefreshResult(updateCount: updateCount, hasUpdate: updateCount > 0);
    } catch (e) {
      return const RefreshResult();
    }
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
