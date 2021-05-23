import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/model/bangumi.dart';

part 'bangumi_row.g.dart';

@HiveType(typeId: MyHive.MIAKN_BANGUMI_ROW)
class BangumiRow extends HiveObject {
  // 周几或者剧场版之类的名称
  @HiveField(0)
  late String name;

  // 周几或者剧场版之类的名称
  @HiveField(1)
  late String sname;

  // 今日有多少部
  @HiveField(2)
  late int num;

  // 更新的部数
  @HiveField(3)
  late int updatedNum;

  //订阅的部数
  @HiveField(4)
  late int subscribedNum;

  //订阅更新的部数
  @HiveField(5)
  late int subscribedUpdatedNum;

  // 这天的番剧
  @HiveField(6)
  late List<Bangumi> bangumis;

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
          bangumis == other.bangumis;

  @override
  int get hashCode =>
      name.hashCode ^
      sname.hashCode ^
      num.hashCode ^
      updatedNum.hashCode ^
      subscribedNum.hashCode ^
      subscribedUpdatedNum.hashCode ^
      bangumis.hashCode;
}
