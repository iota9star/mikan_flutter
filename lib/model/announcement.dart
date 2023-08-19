import 'package:hive_flutter/hive_flutter.dart';

import '../internal/hive.dart';

part 'announcement.g.dart';

@HiveType(typeId: MyHive.mikanAnnouncement)
class Announcement extends HiveObject {
  Announcement({
    required this.date,
    required this.nodes,
  });

  @HiveField(0)
  late String date;
  @HiveField(1)
  late List<AnnouncementNode> nodes;

  late final text = () {
    final sb = StringBuffer()
      ..write('{')
      ..write(date)
      ..write('} ');
    for (final node in nodes) {
      sb.write(node.text);
    }
    return sb.toString();
  }();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Announcement &&
          runtimeType == other.runtimeType &&
          date == other.date;

  @override
  int get hashCode => date.hashCode;

  @override
  String toString() {
    return 'Announcement{date: $date, nodes: $nodes, text: $text}';
  }
}

@HiveType(typeId: MyHive.mikanAnnouncementNode)
class AnnouncementNode extends HiveObject {
  AnnouncementNode({
    required this.text,
    this.type,
    this.place,
  });

  @HiveField(0)
  late String text;
  @HiveField(1)
  String? type;
  @HiveField(2)
  String? place;

  @override
  String toString() {
    return 'AnnouncementNode{text: $text, type: $type, place: $place}';
  }
}
