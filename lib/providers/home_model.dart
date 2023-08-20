import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../internal/extension.dart';
import '../internal/hive.dart';
import '../internal/log.dart';
import '../internal/repo.dart';
import '../topvars.dart';
import '../widget/bottom_sheet.dart';
import '../widget/sliver_pinned_header.dart';
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
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version.split('.').map(int.parse).toList();
      final resp = await Repo.release();
      if (!resp.success) {
        return;
      }
      final lastVersion = (resp.data['tag_name'] as String)
          .replaceAllMapped(RegExp(r'[^\d.]'), (match) => '')
          .split('.')
          .map(int.parse)
          .toList();
      final ignoreVersion = MyHive.db.get(HiveDBKey.ignoreUpdateVersion);
      if (autoCheck && ignoreVersion == lastVersion) {
        return;
      }
      bool hasNewVersion = false;
      for (var i = 0; i < 3; ++i) {
        final o = version[i];
        final n = lastVersion[i];
        if (n > o) {
          hasNewVersion = true;
          break;
        }
      }
      if (hasNewVersion) {
        await Jiffy.setLocale('zh_cn');
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

  Widget _buildUpgradeWidget(
    BuildContext context,
    Map<String, dynamic> release,
  ) {
    final theme = Theme.of(context);
    final jiffy = Jiffy.parse(release['published_at'])..add(hours: 8);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                const SliverPinnedAppBar(title: '发现新版本，嘿嘿嘿...'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: edgeH4,
                          decoration: BoxDecoration(
                            borderRadius: borderRadius2,
                            color: theme.colorScheme.error,
                          ),
                          child: Text(
                            'New ${release["tag_name"]}',
                            style: theme.textTheme.labelSmall!.copyWith(
                              color: theme.colorScheme.onError,
                            ),
                          ),
                        ),
                        sizedBoxH4,
                        Text(
                          '发布于 ${jiffy.yMMMMEEEEdjm}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: sizedBoxH16),
                SliverList.separated(
                  itemBuilder: (context, index) {
                    final item = release['assets'][index];
                    return Padding(
                      padding: edgeH24V12,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name']),
                                sizedBoxH8,
                                Container(
                                  padding: edgeH6V4,
                                  decoration: BoxDecoration(
                                    borderRadius: borderRadius8,
                                    color: theme.colorScheme.primaryContainer,
                                  ),
                                  child: Text(
                                    <String?>{
                                          'arm64-v8a',
                                          'armeabi-v7a',
                                          'x86_64',
                                          'universal',
                                          'win32',
                                        }.firstWhere(
                                          (arch) => item['name'].contains(arch),
                                          orElse: () => null,
                                        ) ??
                                        'universal',
                                    style: theme.textTheme.labelSmall!.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              item['browser_download_url']
                                  .toString()
                                  .launchAppAndCopy();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120.0, 36.0),
                              shape: const RoundedRectangleBorder(
                                borderRadius: borderRadius8,
                              ),
                              textStyle: const TextStyle(fontSize: 12.0),
                            ),
                            icon: const Icon(
                              Icons.download_rounded,
                              size: 16.0,
                            ),
                            label: Text(
                              '${(item['size'] / 1024 / 1024).toStringAsFixed(2)}MB',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: (release['assets'] as List).length,
                  separatorBuilder: (context, index) {
                    return const Divider(
                      thickness: 0.0,
                      height: 1.0,
                      indent: 24.0,
                      endIndent: 24.0,
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(thickness: 0.0, height: 1.0),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Row(
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
                    minimumSize: const Size(0.0, 36.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: borderRadius8,
                    ),
                    backgroundColor: theme.colorScheme.errorContainer,
                  ),
                  child: Text(
                    '下次一定',
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                sizedBoxW12,
                ElevatedButton(
                  onPressed: () {
                    release['html_url'].toString().launchAppAndCopy();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0.0, 36.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: borderRadius8,
                    ),
                  ),
                  child: const Text('前往下载'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
