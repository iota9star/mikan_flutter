import 'dart:ui';

import 'package:mikan_flutter/model/subgroup_bangumi.dart';

class BangumiHome {
  String id;
  String cover;
  String name;
  bool subscribed;
  Map<String, String> more;
  String intro;
  Size coverSize;
  List<SubgroupBangumi> subgroupBangumis;
}
