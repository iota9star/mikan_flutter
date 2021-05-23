import 'dart:ui';

import 'package:mikan_flutter/internal/consts.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/model/subgroup.dart';

class RecordDetail {
  late String id;
  late String cover;
  late String name;
  late bool subscribed;
  late Map<String, String> more;
  late String intro;
  late List<Subgroup> subgroups;

  // 详情地址
  late String url;

  // 标题
  late String title;

  // 磁链地址
  late String magnet;

  // 种子下载地址
  late String torrent;
  late List<String> tags;

  Size? coverSize;

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
    if (more.isSafeNotEmpty) {
      more.forEach((key, value) {
        sb..write(key)..write("：")..write(value)..write("\n");
      });
    }
    if (subgroups.isSafeNotEmpty) {
      sb
        ..write("字幕组：")
        ..write(subgroups.map((e) => e.name).join(" "))
        ..write("\n");
    }
    if (url.isNotBlank) {
      sb..write("详情地址：")..write(url)..write("\n");
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
