// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeasonAdapter extends TypeAdapter<Season> {
  @override
  final int typeId = 8;

  @override
  Season read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Season(
      year: fields[0] as String,
      season: fields[1] as String,
      title: fields[2] as String,
      active: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Season obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.year)
      ..writeByte(1)
      ..write(obj.season)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.active);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
