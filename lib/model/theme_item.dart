import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';

part 'theme_item.g.dart';

@HiveType(typeId: MyHive.THEME_ITEM)
class ThemeItem extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  bool canDelete = true;

  @HiveField(2)
  bool autoMode = true;

  @HiveField(4)
  bool isDark = false;

  @HiveField(5)
  int primaryColor = 0;

  @HiveField(6)
  int accentColor = 0;

  @HiveField(7)
  int lightBackgroundColor = 0;

  @HiveField(8)
  int darkBackgroundColor = 0;

  @HiveField(9)
  int lightScaffoldBackgroundColor = 0;

  @HiveField(10)
  int darkScaffoldBackgroundColor = 0;

  @HiveField(11)
  String? fontFamily;
}
