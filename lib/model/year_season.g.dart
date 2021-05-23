// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'year_season.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class YearSeasonAdapter extends TypeAdapter<YearSeason> {
  @override
  final int typeId = 9;

  @override
  YearSeason read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YearSeason()
      ..year = fields[0] as String
      ..seasons = (fields[1] as List).cast<Season>();
  }

  @override
  void write(BinaryWriter writer, YearSeason obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.year)
      ..writeByte(1)
      ..write(obj.seasons);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearSeasonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
