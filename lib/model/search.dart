import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/subgroup.dart';

class Search {
  List<Bangumi> bangumis;
  List<Subgroup> subgroups;
  List<RecordItem> searchs;

  Search({
    this.bangumis,
    this.subgroups,
    this.searchs,
  });
}
