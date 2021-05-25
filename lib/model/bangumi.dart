import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';

part 'bangumi.g.dart';

@HiveType(typeId: MyHive.MIAKN_BANGUMI)
class Bangumi extends HiveObject {
  // 番剧的id
  @HiveField(0)
  late String id;

  // 更新时间
  @HiveField(1)
  late String updateAt = "";

  // 更新的数量
  @HiveField(2)
  int? num;

  // 标题
  @HiveField(3)
  late String name;

  // 封面
  @HiveField(4)
  late String cover;

  // 是否已订阅
  @HiveField(5)
  late bool subscribed = false;

  @HiveField(6)
  late bool grey = false;

  @HiveField(7)
  Size? coverSize;

  @HiveField(8)
  late String week = "";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bangumi &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          updateAt == other.updateAt &&
          num == other.num &&
          name == other.name &&
          cover == other.cover &&
          subscribed == other.subscribed &&
          grey == other.grey &&
          coverSize == other.coverSize &&
          week == other.week;

  @override
  int get hashCode =>
      id.hashCode ^
      updateAt.hashCode ^
      num.hashCode ^
      name.hashCode ^
      cover.hashCode ^
      subscribed.hashCode ^
      grey.hashCode ^
      coverSize.hashCode ^
      week.hashCode;
}
