import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/models/record_details.dart';
import 'package:mikan/core/models/record_item.dart';

part 'record_detail_provider.g.dart';

@riverpod
Future<RecordDetail> recordDetail(Ref ref, RecordItem record) async {
  if (record.url.isEmpty) {
    return RecordDetail()
      ..name = record.name
      ..url = record.url
      ..title = record.title
      ..subgroups = record.groups
      ..id = record.id
      ..cover = record.cover
      ..tags = record.tags
      ..torrent = record.torrent
      ..magnet = record.magnet;
  }

  final episodeId = record.url.split('/').last;
  return MikanApi.details(episodeId);
}
