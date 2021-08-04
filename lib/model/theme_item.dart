import 'package:hive/hive.dart';
import 'package:mikan_flutter/internal/hive.dart';

part 'theme_item.g.dart';

@HiveType(typeId: MyHive.THEME_ITEM)
class ThemeItem extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late bool canDelete = true;

  @HiveField(2)
  late bool autoMode = true;

  @HiveField(4)
  late bool isDark = false;

  @HiveField(5)
  late int primaryColor = 0;

  @HiveField(6)
  late int accentColor = 0;

  @HiveField(7)
  late int lightBackgroundColor = 0;

  @HiveField(8)
  late int darkBackgroundColor = 0;

  @HiveField(9)
  late int lightScaffoldBackgroundColor = 0;

  @HiveField(10)
  late int darkScaffoldBackgroundColor = 0;

  @HiveField(11)
  String? fontFamily;

  String? fontFamilyName;

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
          fontFamily == other.fontFamily;

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
      fontFamily.hashCode;
}
