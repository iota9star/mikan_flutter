import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../mikan_api.dart';
import '../../../../../shared/internal/extension.dart';
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
  const ListData({this.page = 0, this.records = const [], this.hasReachedEnd = false});

  final int page;
  final List<RecordItem> records;
  final bool hasReachedEnd;

  ListData copyWith({int? page, List<RecordItem>? records, bool? hasReachedEnd}) {
    return ListData(
      page: page ?? this.page,
      records: records ?? this.records,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

@riverpod
class ListNotifier extends _$ListNotifier {
  @override
  AsyncValue<ListData> build() {
    return const AsyncValue.loading();
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
