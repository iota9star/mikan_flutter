import 'dart:ui';

import 'package:mikan_flutter/model/subgroup.dart';

class RecordDetail {
  String id;
  String cover;
  String name;
  bool subscribed;
  Map<String, String> more;
  String intro;
  List<Subgroup> subgroups;

  // 详情地址
  String url;

  // 标题
  String title;

  // 磁链地址
  String magnet;

  // 种子下载地址
  String torrent;
  List<String> tags;

  Size coverSize;

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
