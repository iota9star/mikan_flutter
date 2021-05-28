import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';

@immutable
class NormalRecordItem extends StatelessWidget {
  final int index;
  final RecordItem record;
  final VoidCallback onTap;
  final ThemeData theme;

  const NormalRecordItem({
    required this.index,
    required this.record,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final List<Subgroup> subgroups = record.groups;
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
    return TapScaleContainer(
      onTap: onTap,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Text(
              record.publishAt,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 8.0,
            ),
            child: Tooltip(
              message: record.title,
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                record.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.0,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
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
                  if (!record.tags.isNullOrEmpty)
                    ...List.generate(record.tags.length, (index) {
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
                          record.tags[index],
                          style: titleTagStyle,
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          Row(
            children: <Widget>[
              if (subgroups.isSafeNotEmpty)
                ...List.generate(
                  subgroups.length,
                  (index) {
                    return Tooltip(
                      message: subgroups[index].name,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.subgroup.name,
                            arguments: Routes.subgroup.d(
                              subgroup: subgroups[index],
                            ),
                          );
                        },
                        child: Container(
                          width: 24.0,
                          height: 24.0,
                          margin: EdgeInsets.only(
                            left: index == 0 ? 16.0 : 4.0,
                          ),
                          child: Center(
                            child: Text(
                              subgroups[index].name[0],
                              style: TextStyle(
                                fontSize: 12.0,
                                color:
                                    theme.primaryColor.computeLuminance() < 0.5
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.primaryColor,
                                theme.primaryColor.withOpacity(0.56),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const Spacer(),
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
}
