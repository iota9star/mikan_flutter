import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';

@immutable
class RssRecordItem extends StatelessWidget {
  final int index;
  final RecordItem record;
  final ThemeData theme;
  final VoidCallback onTap;
  final bool enableHero;

  const RssRecordItem({
    Key? key,
    required this.index,
    required this.record,
    required this.onTap,
    required this.theme,
    this.enableHero = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle accentTagStyle = textStyle10WithColor(
      theme.secondary.isDark ? Colors.white : Colors.black,
    );
    final TextStyle primaryTagStyle = textStyle10WithColor(
      theme.primary.isDark ? Colors.white : Colors.black,
    );
    final List<String> tags = record.tags;
    final heroTag = "rss:${record.id}:${record.cover}:${record.torrent}";
    final cover = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CacheImageProvider(record.cover),
          fit: BoxFit.cover,
        ),
      ),
      foregroundDecoration: BoxDecoration(
        color: theme.colorScheme.background.withOpacity(0.87),
      ),
    );
    return ScalableRippleTap(
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
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.bangumi.name,
                      arguments: Routes.bangumi.d(
                        bangumiId: record.id!,
                        cover: record.cover,
                        heroTag: heroTag,
                      ),
                    );
                  },
                  child: Padding(
                    padding: edgeH16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                record.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyle18B,
                              ),
                            ),
                          ],
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
                ),
                Padding(
                  padding: edgeH16T4,
                  child: Text(
                    record.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle13,
                  ),
                ),
                Container(
                  margin: edgeH16T8,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (record.size.isNotBlank)
                          Container(
                            margin: edgeR4,
                            padding: edgeH4V2,
                            decoration: BoxDecoration(color: theme.secondary),
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
                              decoration: BoxDecoration(color: theme.primary),
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
