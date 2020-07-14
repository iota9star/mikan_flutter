class Season {
  String year;
  String season;
  String title;
  bool active;

  Season({
    this.year,
    this.season,
    this.title,
    this.active,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Season &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}
