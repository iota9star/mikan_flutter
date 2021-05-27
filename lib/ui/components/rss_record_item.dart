import 'package:extended_image/extended_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/record_item.dart';
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
    final TextStyle fileTagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: theme.accentColor.computeLuminance() < 0.5
          ? Colors.white
          : Colors.black,
    );
    final TextStyle titleTagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: theme.primaryColor.computeLuminance() < 0.5
          ? Colors.white
          : Colors.black,
    );
    final List<String> tags = record.tags;
    final heroTag = "rss:${record.id}:${record.cover}:${record.torrent}";
    return TapScaleContainer(
      onTap: onTap,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: heroTag,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: Colors.grey.withOpacity(0.2),
                        image: DecorationImage(
                          image: ExtendedNetworkImageProvider(record.cover),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18.0,
                            height: 1.25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          record.publishAt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.0,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Text(
              record.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.0,
                height: 1.25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          Container(
            margin: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 4.0,
            ),
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      right: 4.0,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.accentColor,
                          theme.accentColor.withOpacity(0.56),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    child: Text(
                      record.size,
                      style: fileTagStyle,
                    ),
                  ),
                  if (!tags.isNullOrEmpty)
                    ...List.generate(tags.length, (index) {
                      return Container(
                        margin: EdgeInsets.only(
                          right: 4.0,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withOpacity(0.56),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        child: Text(
                          tags[index],
                          style: titleTagStyle,
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
    );
  }
}
