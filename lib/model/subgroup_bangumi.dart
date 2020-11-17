import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/subgroup.dart';

class SubgroupBangumi {
  String name;
  String dataId;
  List<Subgroup> subgroups;
  bool subscribed;
  List<RecordItem> records;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubgroupBangumi &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          dataId == other.dataId &&
          records.length == other.records.length;

  @override
  int get hashCode =>
      name.hashCode ^ dataId.hashCode ^ records.length.hashCode;
}
