import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/consts.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/model/subgroup.dart';

part 'record_item.g.dart';

@HiveType(typeId: MyHive.MIAKN_RECORD_ITEM)
class RecordItem {
  @HiveField(0)
  String? id;

  @HiveField(1)
  late String name = "";

  @HiveField(2)
  late String cover = "";

  // 标题
  @HiveField(3)
  late String title = "";

  // 发布时间
  @HiveField(4)
  late String publishAt = "";

  // 字幕组
  @HiveField(5, defaultValue: [])
  late List<Subgroup> groups = [];

  // 详情地址
  @HiveField(6)
  late String url = "";

  // 磁链地址
  @HiveField(7)
  late String magnet = "";

  // 文件大小
  @HiveField(8)
  late String size = "";

  // 种子下载地址
  @HiveField(9)
  late String torrent = "";

  @HiveField(10, defaultValue: [])
  late List<String> tags = [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordItem &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  String get shareString {
    final StringBuffer sb = StringBuffer();
    if (name.isNotBlank) {
      sb..write("番组名称：")..write(name)..write("\n");
    }
    if (id.isNotBlank) {
      sb
        ..write("番组地址：")
        ..write(MikanUrl.BASE_URL)
        ..write(MikanUrl.BANGUMI)
        ..write(id)
        ..write("\n");
    }
    if (title.isNotBlank) {
      sb..write("标题：")..write(title)..write("\n");
    }
    if (url.isNotBlank) {
      sb..write("详情地址：")..write(url)..write("\n");
    }
    if (publishAt.isNotBlank) {
      sb..write("发布时间：")..write(publishAt)..write("\n");
    }
    if (size.isNotBlank) {
      sb..write("文件大小：")..write(size)..write("\n");
    }
    if (groups.isSafeNotEmpty) {
      sb
        ..write("字幕组：")
        ..write(groups.map((e) => e.name).join("，"))
        ..write("\n");
    }
    if (tags.isSafeNotEmpty) {
      sb..write("标签：")..write(tags.join("，"))..write("\n");
    }
    if (cover.isNotBlank) {
      sb..write("封面地址：")..write(cover)..write("\n");
    }
    if (magnet.isNotBlank) {
      sb..write("磁链地址：")..write(magnet)..write("\n");
    }
    if (torrent.isNotBlank) {
      sb..write("种子地址：")..write(torrent)..write("\n");
    }
    return sb.toString();
  }
}
