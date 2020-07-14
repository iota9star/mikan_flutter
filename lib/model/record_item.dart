import 'package:mikan_flutter/model/subgroup.dart';

class RecordItem {
  String cover;

  String id;

  // 发布时间
  String publishAt;

  // 字幕组
  List<Subgroup> groups;

  // 详情地址
  String url;

  // 标题
  String title;

  // 磁链地址
  String magnet;

  // 文件大小
  String size;

  // 种子下载地址
  String torrent;

  String name;

  List<String> tags;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordItem &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}
