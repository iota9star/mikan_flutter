// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_details.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordDetailAdapter extends TypeAdapter<RecordDetail> {
  @override
  final typeId = 100;

  @override
  RecordDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordDetail()
      ..id = fields[0] as String?
      ..cover = fields[1] as String
      ..name = fields[2] as String
      ..subscribed = fields[3] as bool
      ..more = (fields[4] as Map).cast<String, String>()
      ..intro = fields[5] as String
      ..subgroups = (fields[6] as List).cast<Subgroup>()
      ..url = fields[7] as String
      ..title = fields[8] as String
      ..magnet = fields[9] as String
      ..torrent = fields[10] as String
      ..tags = (fields[11] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, RecordDetail obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.subgroups)
      ..writeByte(7)
      ..write(obj.url)
      ..writeByte(8)
      ..write(obj.title)
      ..writeByte(9)
      ..write(obj.magnet)
      ..writeByte(10)
      ..write(obj.torrent)
      ..writeByte(11)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
