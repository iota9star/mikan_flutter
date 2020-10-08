import 'package:hive/hive.dart';
import 'package:mikan_flutter/model/hive_ids.dart';

part 'theme.g.dart';

@HiveType(typeId: HiveIds.THEME_ID)
class Theme extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  bool canDelete;
  @HiveField(2)
  bool autoMode;
  @HiveField(3)
  int primaryColor;
  @HiveField(4)
  int accentColor;
  @HiveField(5)
  int lightBackgroundColor;
  @HiveField(6)
  int darkBackgroundColor;
  @HiveField(7)
  int lightScaffoldBackgroundColor;
  @HiveField(8)
  int darkScaffoldBackgroundColor;
  @HiveField(9)
  String fontFamily;

  Theme({
    this.id,
    this.canDelete,
    this.autoMode,
    this.primaryColor,
    this.accentColor,
    this.lightBackgroundColor,
    this.darkBackgroundColor,
    this.lightScaffoldBackgroundColor,
    this.darkScaffoldBackgroundColor,
    this.fontFamily,
  });
}
