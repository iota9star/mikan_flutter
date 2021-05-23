// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IndexAdapter extends TypeAdapter<Index> {
  @override
  final int typeId = 5;

  @override
  Index read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Index(
      years: (fields[0] as List).cast<YearSeason>(),
      bangumiRows: (fields[1] as List).cast<BangumiRow>(),
      rss: (fields[2] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<RecordItem>())),
      carousels: (fields[3] as List).cast<Carousel>(),
      user: fields[4] as User?,
    );
  }

  @override
  void write(BinaryWriter writer, Index obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.years)
      ..writeByte(1)
      ..write(obj.bangumiRows)
      ..writeByte(2)
      ..write(obj.rss)
      ..writeByte(3)
      ..write(obj.carousels)
      ..writeByte(4)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndexAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
