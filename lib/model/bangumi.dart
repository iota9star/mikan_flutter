import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';

part 'bangumi.g.dart';

@HiveType(typeId: MyHive.MIAKN_BANGUMI)
class Bangumi extends HiveObject {
  // 番剧的id
  @HiveField(0)
  String id;

  // 更新时间
  @HiveField(1)
  String updateAt;

  // 更新的数量
  @HiveField(2)
  int num;

  // 标题
  @HiveField(3)
  String name;

  // 封面
  @HiveField(4)
  String cover;

  // 是否已订阅
  @HiveField(5)
  bool subscribed;

  @HiveField(6)
  bool grey;

  @HiveField(7)
  Location location;

  @HiveField(8)
  Size coverSize;

  @HiveField(9)
  String week;

  Bangumi({
    this.id,
    this.updateAt,
    this.num,
    this.name,
    this.cover,
    this.subscribed,
    this.grey,
    this.week,
    this.location,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bangumi &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class Location {
  final int srow;
  final int row;

  const Location(this.srow, this.row);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          srow == other.srow &&
          row == other.row;

  @override
  int get hashCode => srow.hashCode ^ row.hashCode;
}
