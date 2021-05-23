// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bangumi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BangumiAdapter extends TypeAdapter<Bangumi> {
  @override
  final int typeId = 2;

  @override
  Bangumi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bangumi()
      ..id = fields[0] as String
      ..updateAt = fields[1] as String
      ..num = fields[2] as int?
      ..name = fields[3] as String
      ..cover = fields[4] as String
      ..subscribed = fields[5] as bool
      ..grey = fields[6] as bool
      ..coverSize = fields[7] as Size?
      ..week = fields[8] as String;
  }

  @override
  void write(BinaryWriter writer, Bangumi obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.updateAt)
      ..writeByte(2)
      ..write(obj.num)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.cover)
      ..writeByte(5)
      ..write(obj.subscribed)
      ..writeByte(6)
      ..write(obj.grey)
      ..writeByte(7)
      ..write(obj.coverSize)
      ..writeByte(8)
      ..write(obj.week);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BangumiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
