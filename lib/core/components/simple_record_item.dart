import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mikan/features/bangumi/presentation/pages/record.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/models/record_item.dart';
import 'package:mikan/core/widgets/icon_button.dart';
import 'package:mikan/core/widgets/ripple_tap.dart';
import 'package:mikan/core/widgets/transition_container.dart';

/// Provider for current record item - will be overridden
final currentRecordProvider = Provider<RecordItem>((ref) {
  throw UnimplementedError('Must be overridden');
});

/// Record item widget - const, reads data from provider
@immutable
class SimpleRecordItem extends ConsumerWidget {
  const SimpleRecordItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(currentRecordProvider);
    final theme = Theme.of(context);
    final tagStyle = theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onTertiaryContainer);
    final sizeStyle = theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondaryContainer);
    final closedColor = ElevationOverlay.applySurfaceTint(theme.cardColor, theme.colorScheme.surfaceTint, 1.0);

    return TransitionContainer(
      closedColor: closedColor,
      routeSettings: const RouteSettings(name: '/record'),
      builder: (context, open) {
        return RippleTap(
          onTap: open,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(record.title, style: theme.textTheme.bodyMedium),
                const Gap(8),
                Wrap(
                  runSpacing: 6.0,
                  spacing: 6.0,
                  children: [
                    if (record.size.isNotBlank)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                        ),
                        child: Text(record.size, style: sizeStyle),
                      ),
                    if (!record.tags.isNullOrEmpty)
                      for (final tag in record.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                          ),
                          child: Text(tag, style: tagStyle),
                        ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        record.publishAt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const Gap(8),
                    TMSMenuButton(torrent: record.torrent, magnet: record.magnet, share: record.share),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      next: RecordPage(record: record),
    );
  }
}
