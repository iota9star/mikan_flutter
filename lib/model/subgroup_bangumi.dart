import 'record_item.dart';
import 'subgroup.dart';

class SubgroupBangumi {
  late String name;
  late String dataId;
  late List<Subgroup> subgroups;
  late bool subscribed;
  String? sublang;
  String? rss;
  late int state;
  late List<RecordItem> records;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubgroupBangumi &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          dataId == other.dataId &&
          subgroups == other.subgroups &&
          subscribed == other.subscribed &&
          sublang == other.sublang &&
          rss == other.rss &&
          state == other.state &&
          records == other.records;

  @override
  int get hashCode =>
      name.hashCode ^
      dataId.hashCode ^
      subgroups.hashCode ^
      subscribed.hashCode ^
      sublang.hashCode ^
      rss.hashCode ^
      state.hashCode ^
      records.hashCode;
}
