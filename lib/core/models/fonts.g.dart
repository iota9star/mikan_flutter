// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fonts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FontAdapter extends TypeAdapter<Font> {
  @override
  final typeId = 106;

  @override
  Font read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return Font(
      id: fields[0] as String,
      name: fields[1] as String,
      files: (fields[2] as List).cast<String>(),
      desc: fields[3] as String,
      official: fields[4] as String,
      license: fields[5] as License,
    );
  }

  @override
  void write(BinaryWriter writer, Font obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.files)
      ..writeByte(3)
      ..write(obj.desc)
      ..writeByte(4)
      ..write(obj.official)
      ..writeByte(5)
      ..write(obj.license);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FontAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class LicenseAdapter extends TypeAdapter<License> {
  @override
  final typeId = 107;

  @override
  License read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return License(name: fields[1] as String, url: fields[0] as String);
  }

  @override
  void write(BinaryWriter writer, License obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LicenseAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
