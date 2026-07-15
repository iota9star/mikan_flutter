import 'package:hive_ce/hive.dart';

import 'package:mikan/core/common/consts.dart';
import 'package:mikan/core/models/subgroup_bangumi.dart';

part 'bangumi_details.g.dart';

@HiveType(typeId: 103)
class BangumiDetail {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String cover;

  @HiveField(2)
  late String name;

  @HiveField(3)
  late bool subscribed;

  @HiveField(4)
  late Map<String, String> more;

  @HiveField(5)
  late String intro;

  @HiveField(6)
  late Map<String, SubgroupBangumi> subgroupBangumis;

  /// Computed field — excluded from Hive serialization.
  late final String share = '$name\n${MikanUrls.bangumi}/$id';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BangumiDetail &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cover == other.cover &&
          name == other.name &&
          subscribed == other.subscribed &&
          more == other.more &&
          intro == other.intro &&
          subgroupBangumis == other.subgroupBangumis;

  @override
  int get hashCode =>
      id.hashCode ^
      cover.hashCode ^
      name.hashCode ^
      subscribed.hashCode ^
      more.hashCode ^
      intro.hashCode ^
      subgroupBangumis.hashCode;
}
