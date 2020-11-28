import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';

part 'theme_item.g.dart';

@HiveType(typeId: MyHive.THEME_ITEM)
class ThemeItem extends HiveObject {
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

  ThemeItem({
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          canDelete == other.canDelete &&
          autoMode == other.autoMode &&
          primaryColor == other.primaryColor &&
          accentColor == other.accentColor &&
          lightBackgroundColor == other.lightBackgroundColor &&
          darkBackgroundColor == other.darkBackgroundColor &&
          lightScaffoldBackgroundColor == other.lightScaffoldBackgroundColor &&
          darkScaffoldBackgroundColor == other.darkScaffoldBackgroundColor &&
          fontFamily == other.fontFamily;

  @override
  int get hashCode =>
      id.hashCode ^
      canDelete.hashCode ^
      autoMode.hashCode ^
      primaryColor.hashCode ^
      accentColor.hashCode ^
      lightBackgroundColor.hashCode ^
      darkBackgroundColor.hashCode ^
      lightScaffoldBackgroundColor.hashCode ^
      darkScaffoldBackgroundColor.hashCode ^
      fontFamily.hashCode;
}
