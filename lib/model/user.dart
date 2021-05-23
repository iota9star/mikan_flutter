import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';

part 'user.g.dart';

@HiveType(typeId: MyHive.MIAKN_USER)
class User extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  String? avatar;

  @HiveField(2)
  String? token;

  bool get hasLogin => name.isNotBlank && avatar.isNotBlank;

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
