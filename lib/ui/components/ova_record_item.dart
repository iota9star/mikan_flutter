import 'package:flutter/material.dart';

import '../../internal/extension.dart';
import '../../model/record_item.dart';
import '../../topvars.dart';
import '../../widget/icon_button.dart';
import '../../widget/scalable_tap.dart';

@immutable
class OVARecordItem extends StatelessWidget {
  const OVARecordItem({
    super.key,
    required this.index,
    required this.record,
    required this.onTap,
  });

  final int index;
  final RecordItem record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onTertiaryContainer,
    );
    final sizeStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onSecondaryContainer,
    );
    return ScalableCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Tooltip(
              message: record.title,
              padding: edgeH12V8,
              margin: edgeH16,
              child: Text(
                record.title,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            sizedBoxH8,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        runSpacing: 4.0,
                        spacing: 4.0,
                        children: [
                          if (record.size.isNotBlank)
                            Container(
                              padding: edgeH6V4,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: borderRadius8,
                              ),
                              child: Text(
                                record.size,
                                style: sizeStyle,
                              ),
                            ),
                          if (!record.tags.isNullOrEmpty)
                            ...List.generate(
                              record.tags.length,
                              (index) {
                                return Container(
                                  padding: edgeH6V4,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiaryContainer,
                                    borderRadius: borderRadius8,
                                  ),
                                  child: Text(
                                    record.tags[index],
                                    style: tagStyle,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      sizedBoxH4,
                      Text(
                        record.publishAt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                sizedBoxW8,
                TMSMenuButton(
                  torrent: record.torrent,
                  magnet: record.magnet,
                  share: record.share,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
