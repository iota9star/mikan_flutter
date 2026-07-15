// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_gallery.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeasonGalleryAdapter extends TypeAdapter<SeasonGallery> {
  @override
  final typeId = 101;

  @override
  SeasonGallery read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeasonGallery(
      year: fields[0] as String,
      season: fields[1] as String,
      title: fields[2] as String,
      active: fields[3] == null ? false : fields[3] as bool,
      bangumis: (fields[4] as List).cast<Bangumi>(),
    );
  }

  @override
  void write(BinaryWriter writer, SeasonGallery obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.year)
      ..writeByte(1)
      ..write(obj.season)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.active)
      ..writeByte(4)
      ..write(obj.bangumis);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeasonGalleryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
