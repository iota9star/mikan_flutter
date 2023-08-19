import 'package:hive/hive.dart';

import '../internal/hive.dart';

part 'carousel.g.dart';

@HiveType(typeId: MyHive.mikanCarousel)
class Carousel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String cover;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Carousel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cover == other.cover;

  @override
  int get hashCode => id.hashCode ^ cover.hashCode;
}
