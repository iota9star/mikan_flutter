import 'package:easy_refresh/easy_refresh.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../mikan_api.dart';
import '../../../../../shared/internal/extension.dart';
import '../../../../../shared/models/record_item.dart';

part 'recent_subscribed_provider.g.dart';

/// Recent subscribed state - data state
class RecentSubscribedState {
  const RecentSubscribedState({this.records = const [], this.dayOffset = 2});

  final List<RecordItem> records;
  final int dayOffset;

  RecentSubscribedState copyWith({List<RecordItem>? records, int? dayOffset}) {
    return RecentSubscribedState(records: records ?? this.records, dayOffset: dayOffset ?? this.dayOffset);
  }
}

/// Recent subscribed provider - manages subscription data with AsyncValue
@riverpod
class RecentSubscribed extends _$RecentSubscribed {
  @override
  Future<RecentSubscribedState> build(List<RecordItem> records) async {
    // Return initial data directly - the Future makes state an AsyncValue
    return RecentSubscribedState(records: records);
  }

  /// Refresh subscription data
  Future<IndicatorResult> refresh() async {
    final newState = await AsyncValue.guard(() async {
      final data = await MikanApi.day(2);
      return RecentSubscribedState(records: data, dayOffset: 0);
    });
    setIfMounted(ref, newState);

    // Return success if data loaded, otherwise fail
    return state.hasValue ? IndicatorResult.success : IndicatorResult.fail;
  }

  /// Load more subscription data
  Future<IndicatorResult> loadMore() async {
    // Get current dayOffset before loading
    final currentData = state.value;
    if (currentData == null) {
      return IndicatorResult.fail;
    }

    final next = currentData.dayOffset + 2;

    final newState = await AsyncValue.guard(() async {
      final data = await MikanApi.day(next);

      // recent 14 days max
      if (next > 14 && data.length == currentData.records.length) {
        return currentData.copyWith(dayOffset: next); // No more data
      } else {
        return RecentSubscribedState(records: data, dayOffset: next);
      }
    });
    setIfMounted(ref, newState);

    // Return appropriate result
    if (!state.hasValue) {
      return IndicatorResult.fail;
    }

    final newData = state.value!;
    if (newData.dayOffset > 14 && newData.records.length == currentData.records.length) {
      return IndicatorResult.noMore;
    }
    return IndicatorResult.success;
  }
}
