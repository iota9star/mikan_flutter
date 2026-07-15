import 'package:hive_ce/hive.dart';

import 'package:mikan/core/models/bangumi.dart';
import 'package:mikan/core/models/fonts.dart';
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/models/season_gallery.dart';

part 'cached_list.g.dart';

// Hive CE codegen does not support generic type parameters in generated
// adapters (it emits `.cast<T>()` which fails at compile time). We define
// one concrete wrapper per list type instead.

@HiveType(typeId: 108)
class CachedRecordList {
  CachedRecordList(this.items);
  @HiveField(0)
  final List<RecordItem> items;
}

@HiveType(typeId: 109)
class CachedSeasonGalleryList {
  CachedSeasonGalleryList(this.items);
  @HiveField(0)
  final List<SeasonGallery> items;
}

@HiveType(typeId: 110)
class CachedBangumiList {
  CachedBangumiList(this.items);
  @HiveField(0)
  final List<Bangumi> items;
}

@HiveType(typeId: 111)
class CachedFontList {
  CachedFontList(this.items);
  @HiveField(0)
  final List<Font> items;
}
