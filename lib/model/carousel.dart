class Carousel {
  String id;
  String cover;

  Carousel({
    this.id,
    this.cover,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Carousel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cover == other.cover;

  @override
  int get hashCode => id.hashCode ^ cover.hashCode;
}
