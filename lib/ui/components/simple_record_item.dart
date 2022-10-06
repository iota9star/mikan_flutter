import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/icon_button.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';

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
    return TapScaleContainer(
      onTap: onTap,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: borderRadius16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              record.publishAt,
              style: textStyle18B,
            ),
            sizedBoxH8,
            Text(
              record.title,
              style: textStyle15B500,
            ),
            sizedBoxH4,
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: [
                if (record.size.isNotBlank)
                  Container(
                    padding: edgeH4V2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.secondary,
                          theme.secondary.withOpacity(0.56),
                        ],
                      ),
                      borderRadius: borderRadius2,
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.primary,
                            theme.primary.withOpacity(0.56),
                          ],
                        ),
                        borderRadius: borderRadius2,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CustomIconButton(
                  iconData: FluentIcons.arrow_download_24_filled,
                  tooltip: "复制并尝试打开种子链接",
                  backgroundColor: theme.scaffoldBackgroundColor,
                  onPressed: () {
                    record.torrent.launchAppAndCopy();
                  },
                  iconSize: 12.0,
                  size: 28.0,
                ),
                sizedBoxW8,
                CustomIconButton(
                  iconData: FluentIcons.clipboard_link_24_filled,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  tooltip: "复制并尝试打开磁力链接",
                  iconSize: 12.0,
                  size: 28.0,
                  onPressed: () {
                    record.magnet.launchAppAndCopy();
                  },
                ),
                sizedBoxW8,
                CustomIconButton(
                  iconData: FluentIcons.share_24_filled,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  tooltip: "分享",
                  iconSize: 12.0,
                  size: 28.0,
                  onPressed: () {
                    record.shareString.share();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
