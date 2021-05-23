// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemeItemAdapter extends TypeAdapter<ThemeItem> {
  @override
  final int typeId = 1;

  @override
  ThemeItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemeItem()
      ..id = fields[0] as int
      ..canDelete = fields[1] as bool
      ..autoMode = fields[2] as bool
      ..isDark = fields[4] as bool
      ..primaryColor = fields[5] as int
      ..accentColor = fields[6] as int
      ..lightBackgroundColor = fields[7] as int
      ..darkBackgroundColor = fields[8] as int
      ..lightScaffoldBackgroundColor = fields[9] as int
      ..darkScaffoldBackgroundColor = fields[10] as int
      ..fontFamily = fields[11] as String?;
  }

  @override
  void write(BinaryWriter writer, ThemeItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.canDelete)
      ..writeByte(2)
      ..write(obj.autoMode)
      ..writeByte(4)
      ..write(obj.isDark)
      ..writeByte(5)
      ..write(obj.primaryColor)
      ..writeByte(6)
      ..write(obj.accentColor)
      ..writeByte(7)
      ..write(obj.lightBackgroundColor)
      ..writeByte(8)
      ..write(obj.darkBackgroundColor)
      ..writeByte(9)
      ..write(obj.lightScaffoldBackgroundColor)
      ..writeByte(10)
      ..write(obj.darkScaffoldBackgroundColor)
      ..writeByte(11)
      ..write(obj.fontFamily);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
