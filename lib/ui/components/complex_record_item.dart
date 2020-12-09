import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';

@immutable
class ComplexRecordItem extends StatelessWidget {
  final int index;
  final Matrix4 transform;
  final RecordItem record;
  final VoidCallback onTap;
  final VoidCallback onTapStart;
  final VoidCallback onTapEnd;
  final ThemeData theme;

  const ComplexRecordItem({
    @required this.index,
    @required this.record,
    @required this.transform,
    @required this.onTap,
    @required this.onTapStart,
    @required this.onTapEnd,
    @required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final List<Subgroup> subgroups = record.groups;
    final List<String> tags = record.tags;
    return AnimatedTapContainer(
      onTap: onTap,
      onTapEnd: onTapEnd,
      onTapStart: onTapStart,
      transform: transform,
      margin: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        gradient: _createGradientByIndex(theme, index),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            child: Text(
              record.title,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Wrap(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    right: 4.0,
                    bottom: 4.0,
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
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.25,
                      color: theme.accentColor.computeLuminance() < 0.5
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                if (!tags.isNullOrEmpty)
                  ...List.generate(tags.length, (index) {
                    return Container(
                      margin: EdgeInsets.only(
                        right: 4.0,
                        bottom: 4.0,
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
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.25,
                          color: theme.primaryColor.computeLuminance() < 0.5
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    );
                  }),
              ],
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
              Spacer(),
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
              // IconButton(
              //   icon: Icon(FluentIcons.star_24_regular),
              //   color: accentColor,
              //   tooltip: "收藏",
              //   iconSize: 20.0,
              //   onPressed: () {},
              // ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _createGradientByIndex(
    final ThemeData theme,
    final int index,
  ) {
    final Color withOpacity = theme.backgroundColor.withOpacity(0.48);
    switch (index % 6) {
      case 0:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [withOpacity, theme.backgroundColor],
        );
      case 1:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [withOpacity, theme.backgroundColor],
        );
      case 2:
        return LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [withOpacity, theme.backgroundColor],
        );
      case 3:
        return LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [withOpacity, theme.backgroundColor],
        );
      case 4:
        return LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [withOpacity, theme.backgroundColor],
        );
      case 5:
        return LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [withOpacity, theme.backgroundColor],
        );
    }
    return LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [withOpacity, theme.backgroundColor],
    );
  }
}
