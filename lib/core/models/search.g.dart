// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchResultAdapter extends TypeAdapter<SearchResult> {
  @override
  final typeId = 105;

  @override
  SearchResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return SearchResult(
      bangumis: (fields[0] as List).cast<Bangumi>(),
      subgroups: (fields[1] as List).cast<Subgroup>(),
      records: (fields[2] as List).cast<RecordItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, SearchResult obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.bangumis)
      ..writeByte(1)
      ..write(obj.subgroups)
      ..writeByte(2)
      ..write(obj.records);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResultAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
