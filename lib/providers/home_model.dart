import 'package:extended_image/extended_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomeModel extends BaseModel {
  /// default select home page.
  int _selectedIndex = 1;

  int get selectedIndex => _selectedIndex;

  HomeModel() {
    checkAppVersion();
  }

  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  bool _checkingUpgrade = false;

  bool get checkingUpgrade => _checkingUpgrade;

  Future<void> checkAppVersion([bool autoCheck = true]) async {
    if (_checkingUpgrade) return;
    _checkingUpgrade = true;
    notifyListeners();
    try {
      final String pubspec = await rootBundle.loadString("assets/pubspec.yaml");
      final String version = "v${pubspec
              .split("\n")
              .firstWhere((line) => line.startsWith("version:"))
              .split(" ")
              .last
              .split("+")
              .first}";
      final Resp resp = await Repo.release();
      if (!resp.success) return;
      final String lastVersion = resp.data["tag_name"];
      final String ignoreVersion = MyHive.db.get(HiveDBKey.ignoreUpdateVersion);
      // ignore update version.
      if (autoCheck && ignoreVersion == lastVersion) return;
      if (lastVersion.compareTo(version) > 0) {
        showCupertinoModalBottomSheet(
          context: navKey.currentState!.context,
          expand: false,
          topRadius: radius16,
          isDismissible: false,
          enableDrag: false,
          builder: (context) {
            return _buildUpgradeWidget(context, resp.data);
          },
        );
      } else {
        if (!autoCheck) {
          "没有检测到更新".toast();
        }
      }
    } catch (e) {
      e.debug();
    } finally {
      _checkingUpgrade = false;
      notifyListeners();
    }
  }

  Material _buildUpgradeWidget(
    BuildContext context,
    Map<String, dynamic> release,
  ) {
    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = theme.backgroundColor;
    final Color scaffoldBackgroundColor = theme.scaffoldBackgroundColor;
    final Color accentTextColor =
        theme.secondary.isDark ? Colors.white : Colors.black;
    final TextStyle accentTagStyle = textStyle10WithColor(accentTextColor);
    final jiffy = Jiffy(release["published_at"])..add(hours: 8);
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scaffoldBackgroundColor.withOpacity(0.87),
              scaffoldBackgroundColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: edgeHT16B24WithNavbarHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExtendedImage.asset(
                  "assets/mikan.png",
                  height: 42.0,
                  width: 42.0,
                ),
                sizedBoxW12,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "发现新版本，嘿嘿嘿...",
                      style: textStyle16B500,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: edgeH4,
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
                            "New",
                            style: accentTagStyle,
                          ),
                        ),
                        sizedBoxW4,
                        Text(
                          "${release["tag_name"]} ${jiffy.yMMMMEEEEdjm}",
                          style: textStyle12,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
            sizedBoxH8,
            Text(
              "下载速度可能很慢哦，dddd.",
              style: TextStyle(fontSize: 12.0, color: theme.primary),
            ),
            for (final item in release["assets"])
              Container(
                margin: edgeV4,
                padding: edge12,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: borderRadius8,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          item["name"],
                          style: textStyle16B500,
                        ),
                        spacer,
                        MaterialButton(
                          onPressed: () {
                            item["browser_download_url"]
                                .toString()
                                .launchAppAndCopy();
                          },
                          color: theme.secondary,
                          minWidth: 32.0,
                          height: 20.0,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: Icon(
                            FluentIcons.arrow_download_24_regular,
                            size: 14.0,
                            color: accentTextColor,
                          ),
                        ),
                      ],
                    ),
                    sizedBoxH8,
                    Row(
                      children: [
                        Container(
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
                            <String?>{
                                  "arm64-v8a",
                                  "armeabi-v7a",
                                  "x86_64",
                                  "universal",
                                  "win32"
                                }.firstWhere(
                                    (arch) => item["name"].contains(arch),
                                    orElse: () => null) ??
                                "universal",
                            style: accentTagStyle,
                          ),
                        ),
                        spacer,
                        Text(
                          (item["size"] / 1024 / 1024).toStringAsFixed(2) +
                              "MB",
                          style: textStyle12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            sizedBoxH16,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    MyHive.db.put(
                      HiveDBKey.ignoreUpdateVersion,
                      release["tag_name"],
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(96.0, 36.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: borderRadius8,
                    ),
                    primary: scaffoldBackgroundColor,
                  ),
                  child: Text(
                    "下次一定",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: scaffoldBackgroundColor.isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                sizedBoxW12,
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(96.0, 36.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: borderRadius8,
                    ),
                  ),
                  child: Text(
                    "前往下载",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: accentTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
