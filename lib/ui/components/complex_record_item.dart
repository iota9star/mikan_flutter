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
  final Color accentColor;
  final Color primaryColor;
  final Color backgroundColor;
  final TextStyle fileTagStyle;
  final TextStyle titleTagStyle;
  final VoidCallback onTap;
  final VoidCallback onTapStart;
  final VoidCallback onTapEnd;

  const ComplexRecordItem({
    @required this.index,
    @required this.record,
    @required this.accentColor,
    @required this.primaryColor,
    @required this.backgroundColor,
    @required this.fileTagStyle,
    @required this.titleTagStyle,
    @required this.transform,
    @required this.onTap,
    @required this.onTapStart,
    @required this.onTapEnd,
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
        gradient: _createGradientByIndex(index, backgroundColor),
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
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
                        accentColor,
                        accentColor.withOpacity(0.56),
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
                            primaryColor,
                            primaryColor.withOpacity(0.56),
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
                                color: titleTagStyle.color,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryColor,
                                primaryColor.withOpacity(0.56),
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
                color: accentColor,
                iconSize: 20.0,
                onPressed: () {
                  record.torrent.launchApp();
                  record.torrent.copy();
                },
              ),
              IconButton(
                icon: Icon(FluentIcons.clipboard_link_24_regular),
                color: accentColor,
                tooltip: "复制并尝试打开磁力链接",
                iconSize: 20.0,
                onPressed: () {
                  record.magnet.launchApp();
                  record.magnet.copy();
                },
              ),
              IconButton(
                icon: Icon(FluentIcons.share_24_regular),
                color: accentColor,
                tooltip: "分享",
                iconSize: 20.0,
                onPressed: () {
                  record.magnet.share();
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
