import '../internal/consts.dart';
import 'subgroup_bangumi.dart';

class BangumiDetail {
  late String id;
  late String cover;
  late String name;
  late bool subscribed;
  late Map<String, String> more;
  late String intro;
  late Map<String, SubgroupBangumi> subgroupBangumis;

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
