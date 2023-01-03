import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/icon_button.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';

@immutable
class SimpleRecordItem extends StatelessWidget {
  final int index;
  final RecordItem record;
  final ThemeData theme;
  final VoidCallback onTap;

  const SimpleRecordItem({
    Key? key,
    required this.index,
    required this.record,
    required this.onTap,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle accentTagStyle = textStyle10WithColor(
      theme.secondary.isDark ? Colors.white : Colors.black,
    );
    final TextStyle primaryTagStyle = textStyle10WithColor(
      theme.primary.isDark ? Colors.white : Colors.black,
    );
    return ScalableRippleTap(
      onTap: onTap,
      color: theme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              record.title,
              style: textStyle14B500,
            ),
            sizedBoxH8,
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: [
                if (record.size.isNotBlank)
                  Container(
                    padding: edgeH4V2,
                    decoration: BoxDecoration(color: theme.secondary),
                    child: Text(
                      record.size,
                      style: accentTagStyle,
                    ),
                  ),
                if (!record.tags.isNullOrEmpty)
                  ...List.generate(record.tags.length, (index) {
                    return Container(
                      padding: edgeH4V2,
                      decoration: BoxDecoration(color: theme.primary),
                      child: Text(
                        record.tags[index],
                        style: primaryTagStyle,
                      ),
                    );
                  }),
              ],
            ),
            sizedBoxH8,
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    record.publishAt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.caption,
                  ),
                ),
                sizedBoxW8,
                TorrentButton(payload: record.torrent),
                sizedBoxW8,
                MagnetButton(payload: record.magnet),
                sizedBoxW8,
                ShareButton(payload: record.shareString),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
