import 'package:hive_ce/hive.dart';

import 'package:mikan/core/common/consts.dart';
import 'package:mikan/core/models/shareable.dart';
import 'package:mikan/core/models/subgroup.dart';

part 'record_details.g.dart';

@HiveType(typeId: 100)
class RecordDetail {
  /// Hive requires a no-arg default constructor for deserialization; app code
  /// should prefer [RecordDetail.create], whose required parameters make a
  /// missing field a compile-time error instead of a runtime
  /// [LateInitializationError].
  RecordDetail();

  RecordDetail.create({
    this.id,
    this.cover = '',
    required this.name,
    this.subscribed = false,
    Map<String, String>? more,
    this.intro = '',
    List<Subgroup>? subgroups,
    this.url = '',
    required this.title,
    required this.magnet,
    required this.torrent,
    List<String>? tags,
  }) : more = more ?? {},
       subgroups = subgroups ?? [],
       tags = tags ?? [];

  @HiveField(0)
  String? id;

  @HiveField(1)
  String cover = '';

  @HiveField(2)
  late String name;

  @HiveField(3)
  bool subscribed = false;

  @HiveField(4)
  Map<String, String> more = {};

  @HiveField(5)
  String intro = '';

  @HiveField(6)
  List<Subgroup> subgroups = [];

  @HiveField(7)
  late String url = '';

  @HiveField(8)
  late String title;

  @HiveField(9)
  late String magnet;

  @HiveField(10)
  late String torrent;

  @HiveField(11)
  late List<String> tags;

  /// Returns a copy with the given fields replaced.
  RecordDetail copyWith({
    String? id,
    String? cover,
    String? name,
    bool? subscribed,
    Map<String, String>? more,
    String? intro,
    List<Subgroup>? subgroups,
    String? url,
    String? title,
    String? magnet,
    String? torrent,
    List<String>? tags,
  }) {
    return RecordDetail.create(
      id: id ?? this.id,
      cover: cover ?? this.cover,
      name: name ?? this.name,
      subscribed: subscribed ?? this.subscribed,
      more: more ?? this.more,
      intro: intro ?? this.intro,
      subgroups: subgroups ?? this.subgroups,
      url: url ?? this.url,
      title: title ?? this.title,
      magnet: magnet ?? this.magnet,
      torrent: torrent ?? this.torrent,
      tags: tags ?? this.tags,
    );
  }

  /// Computed field — excluded from Hive serialization.
  late final String share = _buildShareText();

  String _buildShareText() {
    final builder = ShareTextBuilder();

    builder.writeField('番组名称：', name);
    builder.writeBangumiUrl(id, MikanUrls.bangumi);
    builder.writeField('标题：', title);
    builder.writeKeyValue(more);
    builder.writeSubgroups(subgroups, ' ');
    builder.writeField('详情地址：', url);
    builder.writeTags(tags);

    return builder.build();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordDetail &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cover == other.cover &&
          name == other.name &&
          subscribed == other.subscribed &&
          more == other.more &&
          intro == other.intro &&
          subgroups == other.subgroups &&
          url == other.url &&
          title == other.title &&
          magnet == other.magnet &&
          torrent == other.torrent &&
          tags == other.tags;

  @override
  int get hashCode =>
      id.hashCode ^
      cover.hashCode ^
      name.hashCode ^
      subscribed.hashCode ^
      more.hashCode ^
      intro.hashCode ^
      subgroups.hashCode ^
      url.hashCode ^
      title.hashCode ^
      magnet.hashCode ^
      torrent.hashCode ^
      tags.hashCode;
}
