import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/model/bangumi.dart';

part 'bangumi_row.g.dart';

@HiveType(typeId: MyHive.MIAKN_BANGUMI_ROW)
class BangumiRow extends HiveObject {
  // 周几或者剧场版之类的名称
  @HiveField(0)
  String name;

  // 周几或者剧场版之类的名称
  @HiveField(1)
  String sname;

  // 今日有多少部
  @HiveField(2)
  int num;

  // 更新的部数
  @HiveField(3)
  int updatedNum;

  //订阅的部数
  @HiveField(4)
  int subscribedNum;

  //订阅更新的部数
  @HiveField(5)
  int subscribedUpdatedNum;

  // 这天的番剧
  @HiveField(6)
  List<Bangumi> bangumis;

  BangumiRow({
    this.name,
    this.sname,
    this.num,
    this.updatedNum,
    this.subscribedNum,
    this.subscribedUpdatedNum,
    this.bangumis,
  });

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
