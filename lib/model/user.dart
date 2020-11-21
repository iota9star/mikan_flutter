class User {
  String name;
  String avatar;
  String token;

  User({
    this.name,
    this.avatar,
    this.token,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          avatar == other.avatar &&
          token == other.token;

  @override
  int get hashCode => name.hashCode ^ avatar.hashCode ^ token.hashCode;
}
