import 'package:hive/hive.dart';

import '../internal/extension.dart';
import '../internal/hive.dart';

part 'user.g.dart';

@HiveType(typeId: MyHive.mikanUser)
class User extends HiveObject {

  User({
    this.name,
    this.avatar,
    this.token,
  });
  @HiveField(0)
  String? name;

  @HiveField(1)
  String? avatar;

  @HiveField(2)
  String? token;

  bool get hasLogin => name.isNotBlank && avatar.isNotBlank;

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
