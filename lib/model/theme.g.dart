// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemeAdapter extends TypeAdapter<Theme> {
  @override
  final int typeId = 1;

  @override
  Theme read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Theme(
      id: fields[0] as int,
      canDelete: fields[1] as bool,
      autoMode: fields[2] as bool,
      primaryColor: fields[3] as int,
      accentColor: fields[4] as int,
      lightBackgroundColor: fields[5] as int,
      darkBackgroundColor: fields[6] as int,
      lightScaffoldBackgroundColor: fields[7] as int,
      darkScaffoldBackgroundColor: fields[8] as int,
      fontFamily: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Theme obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.canDelete)
      ..writeByte(2)
      ..write(obj.autoMode)
      ..writeByte(3)
      ..write(obj.primaryColor)
      ..writeByte(4)
      ..write(obj.accentColor)
      ..writeByte(5)
      ..write(obj.lightBackgroundColor)
      ..writeByte(6)
      ..write(obj.darkBackgroundColor)
      ..writeByte(7)
      ..write(obj.lightScaffoldBackgroundColor)
      ..writeByte(8)
      ..write(obj.darkScaffoldBackgroundColor)
      ..writeByte(9)
      ..write(obj.fontFamily);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
