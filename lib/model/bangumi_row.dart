import 'package:mikan_flutter/model/bangumi.dart';

class BangumiRow {
  // 周几或者剧场版之类的名称
  String name;

  // 这天的番剧
  List<Bangumi> bangumis;

  BangumiRow({
    this.name,
    this.bangumis,
  });
}
