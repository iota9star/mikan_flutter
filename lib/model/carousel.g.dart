// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carousel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CarouselAdapter extends TypeAdapter<Carousel> {
  @override
  final int typeId = 4;

  @override
  Carousel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Carousel()
      ..id = fields[0] as String
      ..cover = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, Carousel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cover);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarouselAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
