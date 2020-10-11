import 'package:mikan_flutter/model/record_item.dart';

class SubgroupBangumi {
  String name;
  String subgroupId;
  bool subscribed;
  List<RecordItem> records;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubgroupBangumi &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          subgroupId == other.subgroupId &&
          records.length == other.records.length;

  @override
  int get hashCode =>
      name.hashCode ^ subgroupId.hashCode ^ records.length.hashCode;
}
