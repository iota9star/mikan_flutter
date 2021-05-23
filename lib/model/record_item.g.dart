// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordItemAdapter extends TypeAdapter<RecordItem> {
  @override
  final int typeId = 10;

  @override
  RecordItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordItem()
      ..id = fields[0] as String?
      ..name = fields[1] as String
      ..cover = fields[2] as String
      ..title = fields[3] as String
      ..publishAt = fields[4] as String
      ..groups = fields[5] == null ? [] : (fields[5] as List).cast<Subgroup>()
      ..url = fields[6] as String
      ..magnet = fields[7] as String
      ..size = fields[8] as String
      ..torrent = fields[9] as String
      ..tags = fields[10] == null ? [] : (fields[10] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, RecordItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.cover)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.publishAt)
      ..writeByte(5)
      ..write(obj.groups)
      ..writeByte(6)
      ..write(obj.url)
      ..writeByte(7)
      ..write(obj.magnet)
      ..writeByte(8)
      ..write(obj.size)
      ..writeByte(9)
      ..write(obj.torrent)
      ..writeByte(10)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
