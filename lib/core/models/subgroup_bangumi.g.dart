// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subgroup_bangumi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubgroupBangumiAdapter extends TypeAdapter<SubgroupBangumi> {
  @override
  final typeId = 104;

  @override
  SubgroupBangumi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return SubgroupBangumi()
      ..name = fields[0] as String
      ..dataId = fields[1] as String
      ..subgroups = (fields[2] as List).cast<Subgroup>()
      ..subscribed = fields[3] as bool
      ..sublang = fields[4] as String?
      ..rss = fields[5] as String?
      ..state = (fields[6] as num).toInt()
      ..records = (fields[7] as List).cast<RecordItem>();
  }

  @override
  void write(BinaryWriter writer, SubgroupBangumi obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.dataId)
      ..writeByte(2)
      ..write(obj.subgroups)
      ..writeByte(3)
      ..write(obj.subscribed)
      ..writeByte(4)
      ..write(obj.sublang)
      ..writeByte(5)
      ..write(obj.rss)
      ..writeByte(6)
      ..write(obj.state)
      ..writeByte(7)
      ..write(obj.records);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubgroupBangumiAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
