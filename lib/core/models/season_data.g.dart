// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeasonDataAdapter extends TypeAdapter<SeasonData> {
  @override
  final typeId = 102;

  @override
  SeasonData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeasonData(
      season: fields[0] as model.Season,
      bangumiRows: (fields[1] as List).cast<BangumiRow>(),
    );
  }

  @override
  void write(BinaryWriter writer, SeasonData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.season)
      ..writeByte(1)
      ..write(obj.bangumiRows);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
