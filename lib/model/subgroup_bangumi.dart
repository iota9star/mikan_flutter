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
          subgroups == other.subgroups &&
          subscribed == other.subscribed &&
          records == other.records;

  @override
  int get hashCode =>
      name.hashCode ^
      dataId.hashCode ^
      subgroups.hashCode ^
      subscribed.hashCode ^
      records.hashCode;
}
