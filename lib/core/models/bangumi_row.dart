import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/models/bangumi.dart';

part 'bangumi_row.g.dart';

@HiveType(typeId: MyHive.mikanBangumiRow)
class BangumiRow extends HiveObject {
  @HiveField(0)
  late String name = '';

  @HiveField(1)
  late String sname = '';

  @HiveField(2)
  late int num = 0;

  @HiveField(3)
  late int updatedNum = 0;

  @HiveField(4)
  late int subscribedNum = 0;

  @HiveField(5)
  late int subscribedUpdatedNum = 0;

  @HiveField(6)
  late List<Bangumi> bangumis = [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BangumiRow &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          sname == other.sname &&
          num == other.num &&
          updatedNum == other.updatedNum &&
          subscribedNum == other.subscribedNum &&
          subscribedUpdatedNum == other.subscribedUpdatedNum &&
          // Structural comparison so two rows carrying the same bangumis
          // compare equal even when the List identity differs.
          listEquals(bangumis, other.bangumis);

  @override
  int get hashCode =>
      name.hashCode ^
      sname.hashCode ^
      num.hashCode ^
      updatedNum.hashCode ^
      subscribedNum.hashCode ^
      subscribedUpdatedNum.hashCode ^
      // Object.hash on the list contents so equal lists hash equally.
      Object.hashAll(bangumis);
}
