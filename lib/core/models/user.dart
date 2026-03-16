import 'package:hive_ce/hive.dart';

import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/hive.dart';

part 'user.g.dart';

@HiveType(typeId: MyHive.mikanUser)
class User extends HiveObject {
  User({this.name, this.avatar, this.token, this.rss});

  @HiveField(0)
  String? name;

  @HiveField(1)
  String? avatar;

  @HiveField(2)
  String? token;

  @HiveField(3)
  String? rss;

  bool get hasLogin => name.isNotBlank && avatar.isNotBlank;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          avatar == other.avatar &&
          token == other.token &&
          rss == other.rss;

  @override
  int get hashCode => name.hashCode ^ avatar.hashCode ^ token.hashCode ^ rss.hashCode;
}
