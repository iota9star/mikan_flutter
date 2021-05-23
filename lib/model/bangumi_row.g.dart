// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bangumi_row.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BangumiRowAdapter extends TypeAdapter<BangumiRow> {
  @override
  final int typeId = 3;

  @override
  BangumiRow read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BangumiRow()
      ..name = fields[0] as String
      ..sname = fields[1] as String
      ..num = fields[2] as int
      ..updatedNum = fields[3] as int
      ..subscribedNum = fields[4] as int
      ..subscribedUpdatedNum = fields[5] as int
      ..bangumis = (fields[6] as List).cast<Bangumi>();
  }

  @override
  void write(BinaryWriter writer, BangumiRow obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.sname)
      ..writeByte(2)
      ..write(obj.num)
      ..writeByte(3)
      ..write(obj.updatedNum)
      ..writeByte(4)
      ..write(obj.subscribedNum)
      ..writeByte(5)
      ..write(obj.subscribedUpdatedNum)
      ..writeByte(6)
      ..write(obj.bangumis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BangumiRowAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
