import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mikan/core/components/simple_record_item.dart';
import 'package:mikan/core/models/record_item.dart';

/// Builds a [SliverChildBuilderDelegate] that materializes a [ProviderScope]
/// per [RecordItem], keyed by the record's stable [RecordItem.url] identity.
///
/// This does two things that the bare `SliverChildBuilderDelegate` does not:
///
/// 1. Assigns a [ValueKey] (record url) to each item so the element tree can
///    reuse state across rebuilds when the list reorders or grows, instead of
///    rebuilding every visible item from scratch.
/// 2. Supplies [SliverChildBuilderDelegate.findChildIndexCallback] so that
///    when a previously-built child moves within the list, the sliver can
///    relocate its existing element by key (O(1) reverse lookup) rather than
///    rebuilding it at a new index. Without this, the framework falls back to
///    a full child reconciliation that re-runs `build` for shifted items.
///
/// The reverse index is built lazily on the first lookup and rebuilt only when
/// the list identity changes, so the cost is one pass over the list per
/// rebuild — identical to the previous materialization cost.
SliverChildBuilderDelegate recordItemDelegate(List<RecordItem> records, Widget child, {Key? sliverKey}) {
  // Lazily-built reverse lookup: url -> index. Rebuilt when [records] is a new
  // list instance (the common case on each provider emission).
  Map<String, int>? indexByUrl;

  int? findChildIndex(Key key) {
    if (key is! ValueKey<String>) {
      return null;
    }
    indexByUrl ??= {for (int i = 0; i < records.length; i++) records[i].url: i};
    return indexByUrl![key.value];
  }

  return SliverChildBuilderDelegate(
    (context, index) {
      final record = records[index];
      return ProviderScope(
        key: ValueKey(record.url),
        overrides: [currentRecordProvider.overrideWithValue(record)],
        child: child,
      );
    },
    childCount: records.length,
    findChildIndexCallback: findChildIndex,
  );
}
