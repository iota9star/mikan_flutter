import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/topvars.dart';
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
      height: 156.0,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: borderRadius16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: edgeHT16,
            child: Text(
              record.publishAt,
              style: textStyle18B,
            ),
          ),
          Padding(
            padding: edgeH16T8,
            child: Tooltip(
              message: record.title,
              padding: edgeH12V8,
              margin: edgeH16,
              child: Text(
                record.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textStyle14B500,
              ),
            ),
          ),
          spacer,
          Container(
            margin: edgeH16,
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
                        margin: edgeR4,
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
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: const Icon(FluentIcons.cloud_download_24_regular),
                tooltip: "复制并尝试打开种子链接",
                color: theme.secondary,
                iconSize: 20.0,
                onPressed: () {
                  record.torrent.launchAppAndCopy();
                },
              ),
              IconButton(
                icon: const Icon(FluentIcons.clipboard_link_24_regular),
                color: theme.secondary,
                tooltip: "复制并尝试打开磁力链接",
                iconSize: 20.0,
                onPressed: () {
                  record.magnet.launchAppAndCopy();
                },
              ),
              IconButton(
                icon: const Icon(FluentIcons.share_24_regular),
                color: theme.secondary,
                tooltip: "分享",
                iconSize: 20.0,
                onPressed: () {
                  record.shareString.share();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
