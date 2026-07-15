// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bangumi_details.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BangumiDetailAdapter extends TypeAdapter<BangumiDetail> {
  @override
  final typeId = 103;

  @override
  BangumiDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BangumiDetail()
      ..id = fields[0] as String
      ..cover = fields[1] as String
      ..name = fields[2] as String
      ..subscribed = fields[3] as bool
      ..more = (fields[4] as Map).cast<String, String>()
      ..intro = fields[5] as String
      ..subgroupBangumis = (fields[6] as Map).cast<String, SubgroupBangumi>();
  }

  @override
  void write(BinaryWriter writer, BangumiDetail obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cover)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.subscribed)
      ..writeByte(4)
      ..write(obj.more)
      ..writeByte(5)
      ..write(obj.intro)
      ..writeByte(6)
      ..write(obj.subgroupBangumis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BangumiDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
