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
    required this.index,
    required this.record,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle fileTagStyle = textStyle10WithColor(
      theme.accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    final TextStyle titleTagStyle = textStyle10WithColor(
      theme.primaryColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    return TapScaleContainer(
      onTap: onTap,
      margin: edgeH16V8,
      decoration: BoxDecoration(
        gradient: _createGradientByIndex(index, theme.backgroundColor),
        borderRadius: borderRadius16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            child: Text(
              record.title,
              style: textStyle14,
            ),
          ),
          Padding(
            padding: edgeH16T8,
            child: Wrap(
              children: [
                Container(
                  margin: edgeRB4,
                  padding: edgeH4V2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.accentColor,
                        theme.accentColor.withOpacity(0.56),
                      ],
                    ),
                    borderRadius: borderRadius2,
                  ),
                  child: Text(
                    record.size,
                    style: fileTagStyle,
                  ),
                ),
                if (!record.tags.isNullOrEmpty)
                  ...List.generate(record.tags.length, (index) {
                    return Container(
                      margin: edgeRB4,
                      padding: edgeH4V2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.56),
                          ],
                        ),
                        borderRadius: borderRadius2,
                      ),
                      child: Text(
                        record.tags[index],
                        style: titleTagStyle,
                      ),
                    );
                  }),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(FluentIcons.cloud_download_24_regular),
                tooltip: "复制并尝试打开种子链接",
                color: theme.accentColor,
                iconSize: 20.0,
                onPressed: () {
                  record.torrent.launchAppAndCopy();
                },
              ),
              IconButton(
                icon: Icon(FluentIcons.clipboard_link_24_regular),
                color: theme.accentColor,
                tooltip: "复制并尝试打开磁力链接",
                iconSize: 20.0,
                onPressed: () {
                  record.magnet.launchAppAndCopy();
                },
              ),
              IconButton(
                icon: Icon(FluentIcons.share_24_regular),
                color: theme.accentColor,
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

  LinearGradient _createGradientByIndex(
    final int index,
    final Color backgroundColor,
  ) {
    final Color withOpacity = backgroundColor.withOpacity(0.48);
    switch (index % 6) {
      case 0:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [withOpacity, backgroundColor],
        );
      case 1:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [withOpacity, backgroundColor],
        );
      case 2:
        return LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [withOpacity, backgroundColor],
        );
      case 3:
        return LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [withOpacity, backgroundColor],
        );
      case 4:
        return LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [withOpacity, backgroundColor],
        );
      case 5:
        return LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [withOpacity, backgroundColor],
        );
    }
    return LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [withOpacity, backgroundColor],
    );
  }
}
