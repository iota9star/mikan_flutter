import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';

part 'theme_item.g.dart';

@HiveType(typeId: MyHive.THEME_ITEM)
class ThemeItem extends HiveObject {
  static const String THEME_VERSION_V1 = "v1";

  @HiveField(0)
  int id;

  @HiveField(1)
  bool canDelete;

  @HiveField(2)
  bool autoMode;

  @HiveField(4)
  bool isDark;

  @HiveField(5)
  int primaryColor;

  @HiveField(6)
  int accentColor;

  @HiveField(7)
  int lightBackgroundColor;

  @HiveField(8)
  int darkBackgroundColor;

  @HiveField(9)
  int lightScaffoldBackgroundColor;

  @HiveField(10)
  int darkScaffoldBackgroundColor;

  @HiveField(11)
  String fontFamily;

  @HiveField(255)
  String version;

  ThemeItem({
    this.id,
    this.canDelete,
    this.autoMode,
    this.isDark,
    this.primaryColor,
    this.accentColor,
    this.lightBackgroundColor,
    this.darkBackgroundColor,
    this.lightScaffoldBackgroundColor,
    this.darkScaffoldBackgroundColor,
    this.fontFamily,
    this.version,
  });

  ThemeItem.create({
    this.id,
    this.canDelete,
    this.autoMode,
    this.isDark,
    this.primaryColor,
    this.accentColor,
    this.lightBackgroundColor,
    this.darkBackgroundColor,
    this.lightScaffoldBackgroundColor,
    this.darkScaffoldBackgroundColor,
    this.fontFamily,
    this.version = THEME_VERSION_V1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          canDelete == other.canDelete &&
          autoMode == other.autoMode &&
          isDark == other.isDark &&
          primaryColor == other.primaryColor &&
          accentColor == other.accentColor &&
          lightBackgroundColor == other.lightBackgroundColor &&
          darkBackgroundColor == other.darkBackgroundColor &&
          lightScaffoldBackgroundColor == other.lightScaffoldBackgroundColor &&
          darkScaffoldBackgroundColor == other.darkScaffoldBackgroundColor &&
          fontFamily == other.fontFamily &&
          version == other.version;

  @override
  int get hashCode =>
      id.hashCode ^
      canDelete.hashCode ^
      autoMode.hashCode ^
      isDark.hashCode ^
      primaryColor.hashCode ^
      accentColor.hashCode ^
      lightBackgroundColor.hashCode ^
      darkBackgroundColor.hashCode ^
      lightScaffoldBackgroundColor.hashCode ^
      darkScaffoldBackgroundColor.hashCode ^
      fontFamily.hashCode ^
      version.hashCode;
}
