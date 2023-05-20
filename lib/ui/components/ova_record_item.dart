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
    final accentTagStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.secondary.isDark ? Colors.white : Colors.black,
    );
    final primaryTagStyle = accentTagStyle?.copyWith(
      color: theme.primary.isDark ? Colors.white : Colors.black,
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
                          if (!record.tags.isNullOrEmpty)
                            ...List.generate(
                              record.tags.length,
                              (index) {
                                return Container(
                                  padding: edgeH4V2,
                                  decoration: BoxDecoration(
                                    color: theme.primary,
                                    borderRadius: borderRadius4,
                                  ),
                                  child: Text(
                                    record.tags[index],
                                    style: primaryTagStyle,
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
