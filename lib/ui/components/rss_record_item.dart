import 'package:flutter/material.dart';

import '../../internal/extension.dart';
import '../../internal/image_provider.dart';
import '../../mikan_routes.dart';
import '../../model/record_item.dart';
import '../../topvars.dart';
import '../../widget/icon_button.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/scalable_tap.dart';

@immutable
class RssRecordItem extends StatelessWidget {
  const RssRecordItem({
    super.key,
    required this.index,
    required this.record,
    required this.onTap,
    this.enableHero = true,
  });

  final int index;
  final RecordItem record;
  final VoidCallback onTap;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentTagStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.secondary.isDark ? Colors.white : Colors.black,
      height: 1.25,
    );
    final primaryTagStyle = accentTagStyle?.copyWith(
      color: theme.primary.isDark ? Colors.white : Colors.black,
    );
    final List<String> tags = record.tags;
    final heroTag = 'rss:${record.id}:${record.cover}:${record.torrent}';
    final cover = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CacheImage(record.cover),
          fit: BoxFit.cover,
        ),
      ),
      foregroundDecoration: BoxDecoration(
        color: theme.colorScheme.background.withOpacity(0.87),
      ),
    );
    return ScalableCard(
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: enableHero
                ? Hero(
                    tag: heroTag,
                    child: cover,
                  )
                : cover,
          ),
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RippleTap(
                  borderRadius: borderRadius12,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.bangumi.name,
                      arguments: Routes.bangumi.d(
                        bangumiId: record.id!,
                        cover: record.cover,
                        heroTag: heroTag,
                        title: record.name,
                      ),
                    );
                  },
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
                ),
                spacer,
                Padding(
                  padding: edgeH16,
                  child: Text(
                    '${record.title}\n',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Container(
                  padding: edgeHB16T4,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (record.size.isNotBlank)
                          Container(
                            margin: edgeR4,
                            padding: edgeH4V2,
                            decoration: BoxDecoration(
                              color: theme.secondary,
                              borderRadius: borderRadius4,
                            ),
                            child: Text(
                              record.size,
                              style: accentTagStyle,
                            ),
                          ),
                        if (!tags.isNullOrEmpty)
                          for (final tag in tags)
                            Container(
                              margin: edgeR4,
                              padding: edgeH4V2,
                              decoration: BoxDecoration(
                                color: theme.primary,
                                borderRadius: borderRadius4,
                              ),
                              child: Text(
                                tag,
                                style: primaryTagStyle,
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
