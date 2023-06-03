// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnnouncementAdapter extends TypeAdapter<Announcement> {
  @override
  final int typeId = 11;

  @override
  Announcement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Announcement(
      date: fields[0] as String,
      nodes: (fields[1] as List).cast<AnnouncementNode>(),
    );
  }

  @override
  void write(BinaryWriter writer, Announcement obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.nodes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnnouncementNodeAdapter extends TypeAdapter<AnnouncementNode> {
  @override
  final int typeId = 12;

  @override
  AnnouncementNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnnouncementNode(
      place: fields[3] as String?,
      text: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AnnouncementNode obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.place);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
