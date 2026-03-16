import 'package:mikan/core/common/consts.dart';
import 'package:mikan/core/models/shareable.dart';
import 'package:mikan/core/models/subgroup.dart';

class RecordDetail {
  String? id;
  String cover = '';
  late String name;
  bool subscribed = false;
  Map<String, String> more = {};
  String intro = '';
  List<Subgroup> subgroups = [];

  late String url = '';

  late String title;

  late String magnet;

  late String torrent;
  late List<String> tags;

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
