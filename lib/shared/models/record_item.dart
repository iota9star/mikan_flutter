import 'package:hive_ce/hive.dart';

import '../internal/consts.dart';
import '../internal/hive.dart';
import 'shareable.dart';
import 'subgroup.dart';

part 'record_item.g.dart';

@HiveType(typeId: MyHive.mikanRecordItem)
class RecordItem {
  @HiveField(0)
  String? id;

  @HiveField(1)
  late String name = '';

  @HiveField(2)
  late String cover = '';

  @HiveField(3)
  late String title = '';

  @HiveField(4)
  late String publishAt = '';

  @HiveField(5, defaultValue: [])
  late List<Subgroup> groups = [];

  @HiveField(6)
  late String url = '';

  @HiveField(7)
  late String magnet = '';

  @HiveField(8)
  late String size = '';

  @HiveField(9)
  late String torrent = '';

  @HiveField(10, defaultValue: [])
  late List<String> tags = [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RecordItem && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;

  late final String share = _buildShareText();

  String _buildShareText() {
    final builder = ShareTextBuilder();

    builder.writeField('番组名称：', name);
    builder.writeBangumiUrl(id, MikanUrls.bangumi);
    builder.writeField('标题：', title);
    builder.writeField('详情地址：', url);
    builder.writeField('发布时间：', publishAt);
    builder.writeField('文件大小：', size);
    builder.writeSubgroups(groups, '，');
    builder.writeTags(tags);

    return builder.build();
  }
}
