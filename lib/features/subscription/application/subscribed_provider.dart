import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/models/bangumi.dart';
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/models/season.dart';

part 'subscribed_provider.g.dart';

@riverpod
Future<List<Bangumi>> subscribedBangumis(Ref ref, Season? season) async {
  if (season == null) {
    return [];
  }
  return MikanApi.mySubscribedSeasonBangumi(season.year, season.season);
}

@riverpod
Future<List<RecordItem>> recentRecords(Ref ref) async {
  return MikanApi.day(2);
}

@riverpod
Map<String, List<RecordItem>> rssRecords(Ref ref) {
  final recordsAsync = ref.watch(recentRecordsProvider);

  return recordsAsync.when(
    data: (records) => groupBy(records.where((it) => it.id?.isNotEmpty ?? false), (it) => it.id!),
    loading: () => {},
    error: (_, __) => {},
  );
}
