import 'package:flutter/material.dart';

import '../../internal/extension.dart';
import '../../model/record_item.dart';
import '../../topvars.dart';
import '../../widget/icon_button.dart';
import '../../widget/scalable_tap.dart';

@immutable
class SimpleRecordItem extends StatelessWidget {
  const SimpleRecordItem({
    super.key,
    required this.index,
    required this.record,
    required this.onTap,
    required this.theme,
  });

  final int index;
  final RecordItem record;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentTagStyle = theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
    );
    final primaryTagStyle = accentTagStyle.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return ScalableCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              record.title,
              style: theme.textTheme.bodyMedium,
            ),
            sizedBoxH8,
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        runSpacing: 4.0,
                        spacing: 4.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
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
                            ...List.generate(record.tags.length, (index) {
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
                            }),
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
