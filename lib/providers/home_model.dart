import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';

import '../internal/extension.dart';
import '../internal/hive.dart';
import '../internal/http.dart';
import '../internal/log.dart';
import '../internal/repo.dart';
import '../topvars.dart';
import '../widget/bottom_sheet.dart';
import 'base_model.dart';

class HomeModel extends BaseModel {
  HomeModel() {
    checkAppVersion();
  }

  bool _checkingUpgrade = false;

  bool get checkingUpgrade => _checkingUpgrade;

  Future<void> checkAppVersion([bool autoCheck = true]) async {
    if (_checkingUpgrade) {
      return;
    }
    _checkingUpgrade = true;
    notifyListeners();
    try {
      final String pubspec = await rootBundle.loadString('assets/pubspec.yaml');
      final String version =
          "v${pubspec.split("\n").firstWhere((line) => line.startsWith("version:")).split(" ").last.split("+").first}";
      final Resp resp = await Repo.release();
      if (!resp.success) {
        return;
      }
      final String lastVersion = resp.data['tag_name'];
      final String ignoreVersion = MyHive.db.get(HiveDBKey.ignoreUpdateVersion);
      // ignore update version.
      if (autoCheck && ignoreVersion == lastVersion) {
        return;
      }
      if (lastVersion.compareTo(version) > 0) {
        unawaited(
          // ignore: use_build_context_synchronously
          MBottomSheet.show(
            navKey.currentState!.context,
            (context) => MBottomSheet(
              child: _buildUpgradeWidget(context, resp.data),
            ),
          ),
        );
      } else {
        if (!autoCheck) {
          '没有检测到更新'.toast();
        }
      }
    } catch (e, s) {
      e.$error(stackTrace: s);
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
    final Color backgroundColor = theme.colorScheme.background;
    final Color scaffoldBackgroundColor = theme.scaffoldBackgroundColor;
    final Color accentTextColor =
        theme.secondary.isDark ? Colors.white : Colors.black;
    final jiffy = Jiffy.parse(release['published_at'])..add(hours: 8);
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
        padding: edgeHT16B24WithNavbarHeight(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/mikan.png',
                  height: 42.0,
                  width: 42.0,
                ),
                sizedBoxW12,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '发现新版本，嘿嘿嘿...',
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
                          child: const Text(
                            'New',
                          ),
                        ),
                        sizedBoxW4,
                        Text(
                          "${release["tag_name"]} ${jiffy.yMMMMEEEEdjm}",
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
              '下载速度可能很慢哦，dddd.',
              style: TextStyle(fontSize: 12.0, color: theme.primary),
            ),
            for (final item in release['assets'])
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
                          item['name'],
                        ),
                        spacer,
                        MaterialButton(
                          onPressed: () {
                            item['browser_download_url']
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
                            Icons.download_rounded,
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
                                  'arm64-v8a',
                                  'armeabi-v7a',
                                  'x86_64',
                                  'universal',
                                  'win32'
                                }.firstWhere(
                                  (arch) => item['name'].contains(arch),
                                  orElse: () => null,
                                ) ??
                                'universal',
                          ),
                        ),
                        spacer,
                        Text(
                          (item['size'] / 1024 / 1024).toStringAsFixed(2) +
                              'MB',
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
                      release['tag_name'],
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(96.0, 36.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: borderRadius8,
                    ),
                    backgroundColor: scaffoldBackgroundColor,
                  ),
                  child: Text(
                    '下次一定',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
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
                    '前往下载',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
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
