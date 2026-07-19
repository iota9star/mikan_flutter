import 'package:hive_ce/hive.dart';

import 'package:mikan/core/common/consts.dart';
import 'package:mikan/core/models/subgroup_bangumi.dart';

part 'bangumi_details.g.dart';

@HiveType(typeId: 103)
class BangumiDetail {
  /// Hive requires a no-arg default constructor for deserialization; app code
  /// should prefer [BangumiDetail.create], whose required parameters make a
  /// missing field a compile-time error instead of a runtime
  /// [LateInitializationError].
  BangumiDetail();

  BangumiDetail.create({
    required this.id,
    required this.cover,
    required this.name,
    required this.subscribed,
    required this.more,
    required this.intro,
    required this.subgroupBangumis,
  });

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

  /// Returns a copy of this detail with the given fields replaced. Centralizes
  /// the cascade-copy pattern so callers can't silently drop a field.
  BangumiDetail copyWith({
    String? id,
    String? cover,
    String? name,
    bool? subscribed,
    Map<String, String>? more,
    String? intro,
    Map<String, SubgroupBangumi>? subgroupBangumis,
  }) {
    return BangumiDetail.create(
      id: id ?? this.id,
      cover: cover ?? this.cover,
      name: name ?? this.name,
      subscribed: subscribed ?? this.subscribed,
      more: more ?? this.more,
      intro: intro ?? this.intro,
      subgroupBangumis: subgroupBangumis ?? this.subgroupBangumis,
    );
  }

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
