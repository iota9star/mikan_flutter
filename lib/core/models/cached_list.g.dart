// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedRecordListAdapter extends TypeAdapter<CachedRecordList> {
  @override
  final typeId = 108;

  @override
  CachedRecordList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return CachedRecordList((fields[0] as List).cast<RecordItem>());
  }

  @override
  void write(BinaryWriter writer, CachedRecordList obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedRecordListAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class CachedSeasonGalleryListAdapter extends TypeAdapter<CachedSeasonGalleryList> {
  @override
  final typeId = 109;

  @override
  CachedSeasonGalleryList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return CachedSeasonGalleryList((fields[0] as List).cast<SeasonGallery>());
  }

  @override
  void write(BinaryWriter writer, CachedSeasonGalleryList obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedSeasonGalleryListAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class CachedBangumiListAdapter extends TypeAdapter<CachedBangumiList> {
  @override
  final typeId = 110;

  @override
  CachedBangumiList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return CachedBangumiList((fields[0] as List).cast<Bangumi>());
  }

  @override
  void write(BinaryWriter writer, CachedBangumiList obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedBangumiListAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class CachedFontListAdapter extends TypeAdapter<CachedFontList> {
  @override
  final typeId = 111;

  @override
  CachedFontList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return CachedFontList((fields[0] as List).cast<Font>());
  }

  @override
  void write(BinaryWriter writer, CachedFontList obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedFontListAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
