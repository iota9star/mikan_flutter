import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';

@immutable
class RssRecordItem extends StatelessWidget {
  final int index;
  final RecordItem record;
  final ThemeData theme;
  final VoidCallback onTap;

  const RssRecordItem({
    required this.index,
    required this.record,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle accentTagStyle = textStyle10WithColor(
      theme.accentColor.isDark ? Colors.white : Colors.black,
    );
    final TextStyle primaryTagStyle = textStyle10WithColor(
      theme.primaryColor.isDark ? Colors.white : Colors.black,
    );
    final List<String> tags = record.tags;
    final heroTag = "rss:${record.id}:${record.cover}:${record.torrent}";
    return TapScaleContainer(
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: heroTag,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius16,
                  image: DecorationImage(
                    image: FastCacheImage(record.cover),
                    fit: BoxFit.cover,
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: borderRadius16,
                  gradient: LinearGradient(
                    colors: [
                      theme.backgroundColor.withOpacity(0.64),
                      theme.backgroundColor.withOpacity(0.87),
                      theme.backgroundColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    padding: edgeHT16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle18B,
                        ),
                        Text(
                          record.publishAt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle12,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: edgeH16T8,
                  child: Text(
                    record.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle15B500,
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
                                  theme.accentColor,
                                  theme.accentColor.withOpacity(0.56),
                                ],
                              ),
                              borderRadius: borderRadius2,
                            ),
                            child: Text(
                              record.size,
                              style: accentTagStyle,
                            ),
                          ),
                        if (!tags.isNullOrEmpty)
                          ...List.generate(tags.length, (index) {
                            return Container(
                              margin: edgeR4,
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
                                tags[index],
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
                      icon: Icon(FluentIcons.cloud_download_24_regular),
                      tooltip: "复制并尝试打开种子链接",
                      color: theme.accentColor,
                      iconSize: 20.0,
                      onPressed: () {
                        record.torrent.launchAppAndCopy();
                        record.torrent.copy();
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
          )
        ],
      ),
    );
  }
}
