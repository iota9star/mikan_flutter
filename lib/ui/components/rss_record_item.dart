import 'package:flutter/material.dart';

import '../../internal/extension.dart';
import '../../internal/image_provider.dart';
import '../../model/record_item.dart';
import '../../topvars.dart';
import '../../widget/icon_button.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/transition_container.dart';
import '../pages/bangumi.dart';
import '../pages/record.dart';

@immutable
class RssRecordItem extends StatelessWidget {
  const RssRecordItem({
    super.key,
    required this.index,
    required this.record,
  });

  final int index;
  final RecordItem record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = record.tags;
    final cover = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CacheImage(record.cover),
          fit: BoxFit.cover,
        ),
      ),
      foregroundDecoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.87),
      ),
    );
    final tagStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onTertiaryContainer,
    );
    final sizeStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onSecondaryContainer,
    );
    return TransitionContainer(
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
                  TransitionContainer(
                    builder: (context, open) {
                      return RippleTap(
                        borderRadius: borderRadius6,
                        onTap: open,
                        child: Padding(
                          padding: edgeH16V12,
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
                                    Text(
                                      record.publishAt,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              TMSMenuButton(
                                torrent: record.torrent,
                                magnet: record.magnet,
                                share: record.share,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    next: BangumiPage(
                      bangumiId: record.id!,
                      cover: record.cover,
                      name: record.name,
                    ),
                  ),
                  Padding(
                    padding: edgeH16,
                    child: Text(
                      record.title,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Container(
                    padding: edgeHB16T8,
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: [
                        if (record.size.isNotBlank)
                          Container(
                            padding: edgeH6V4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: borderRadius6,
                            ),
                            child: Text(record.size, style: sizeStyle),
                          ),
                        if (!tags.isNullOrEmpty)
                          for (final tag in tags)
                            Container(
                              padding: edgeH6V4,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiaryContainer,
                                borderRadius: borderRadius6,
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
}
