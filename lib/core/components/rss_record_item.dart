import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mikan/features/bangumi/presentation/pages/bangumi.dart';
import 'package:mikan/features/bangumi/presentation/pages/record.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/widgets/icon_button.dart';
import 'package:mikan/core/widgets/pixa_image.dart';
import 'package:mikan/core/widgets/ripple_tap.dart';
import 'package:mikan/core/widgets/transition_container.dart';
import 'package:mikan/core/components/simple_record_item.dart';

/// Record item widget - const, reads data from provider
@immutable
class RssRecordItem extends ConsumerWidget {
  const RssRecordItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final record = ref.watch(currentRecordProvider);
    final tags = record.tags;
    final bangumiId = record.id;
    final cover = Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: pixaNetworkProvider(record.cover, targetWidth: 500), fit: BoxFit.cover),
      ),
      foregroundDecoration: BoxDecoration(color: theme.colorScheme.surface.withValues(alpha: 0.87)),
    );
    final tagStyle = theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onTertiaryContainer);
    final sizeStyle = theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondaryContainer);
    return TransitionContainer(
      routeSettings: const RouteSettings(name: '/record'),
      builder: (context, open) {
        return RippleTap(
          onTap: open,
          child: Stack(
            children: [
              Positioned.fill(child: cover),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBangumiInfo(context, theme, record, bangumiId),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(record.title, style: theme.textTheme.bodySmall),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
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
                        if (!tags.isNullOrEmpty)
                          for (final tag in tags)
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
                  ),
                ],
              ),
            ],
          ),
        );
      },
      next: RecordPage(record: record),
    );
  }

  /// Builds the bangumi info section with safe null handling for bangumiId.
  Widget _buildBangumiInfo(BuildContext context, ThemeData theme, record, String? bangumiId) {
    final infoContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tooltip(
                  message: record.name,
                  child: Text(
                    record.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(record.publishAt, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          TMSMenuButton(torrent: record.torrent, magnet: record.magnet, share: record.share),
        ],
      ),
    );

    // If bangumiId is null, don't wrap with navigation
    if (bangumiId == null) {
      return infoContent;
    }

    return TransitionContainer(
      routeSettings: const RouteSettings(name: '/bangumi'),
      builder: (context, open) {
        return RippleTap(borderRadius: const BorderRadius.all(Radius.circular(6.0)), onTap: open, child: infoContent);
      },
      next: BangumiPage(bangumiId: bangumiId, cover: record.cover, name: record.name),
    );
  }
}
