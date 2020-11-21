class Subgroup {
  String id;
  String name;

  Subgroup({
    this.id,
    this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subgroup &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
