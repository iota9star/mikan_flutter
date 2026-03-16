import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/models/season_gallery.dart';
import 'package:mikan/core/models/subgroup.dart';

part 'subgroup_provider.g.dart';

@riverpod
Future<List<SeasonGallery>> subgroupGalleries(Ref ref, Subgroup subgroup) async {
  final id = subgroup.id;
  if (id == null) {
    return [];
  }
  return MikanApi.subgroup(id);
}
