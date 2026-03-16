import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:jiffy/jiffy.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mikan/core/api/mikan_api.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/core/common/consts.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/common/log.dart';
import 'package:mikan/core/widgets/bottom_sheet.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';

/// Service for checking and handling app updates
/// Not a Riverpod provider because it's a one-time check on app launch
class UpdateService {
  UpdateService._();

  static bool _isChecking = false;

  /// Check for app updates
  /// [autoCheck] - if true, won't show update dialog for ignored versions
  static Future<void> checkAppVersion([bool autoCheck = true]) async {
    if (_isChecking) {
      return;
    }
    _isChecking = true;

    try {
      if (APP_CHANNEL == 'play') {
        await _checkPlayStoreUpdate();
      } else {
        await _checkGithubRelease(autoCheck);
      }
    } finally {
      _isChecking = false;
    }
  }

  static Future<void> _checkPlayStoreUpdate() async {
    try {
      final v = await InAppUpdate.checkForUpdate().then(
        (v) {
          return (
            availability: v.updateAvailability == UpdateAvailability.updateAvailable,
            immediateUpdateAllowed: v.immediateUpdateAllowed,
            flexibleUpdateAllowed: v.flexibleUpdateAllowed,
          );
        },
        onError: (e, s) {
          return (availability: false, immediateUpdateAllowed: false, flexibleUpdateAllowed: false);
        },
      );
      if (v.availability) {
        if (v.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (v.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
        }
      }
    } catch (e, s) {
      e.$error(stackTrace: s);
    }
  }

  static Future<void> _checkGithubRelease(bool autoCheck) async {
    final context = navKey.currentState?.context;
    if (context == null) {
      return;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = _parseVersionSegments(packageInfo.version);
      final releaseData = await MikanApi.release();
      if (releaseData == null) {
        return;
      }
      final releaseTag = releaseData['tag_name']?.toString();
      if (releaseTag == null || releaseTag.isEmpty) {
        return;
      }
      final lastVersion = _parseVersionSegments(releaseTag);
      if (lastVersion.isEmpty) {
        return;
      }
      final ignoreVersion = MyHive.db.get(HiveDBKey.ignoreUpdateVersion);
      if (autoCheck && ignoreVersion == releaseTag) {
        return;
      }
      final hasNewVersion = _compareVersions(lastVersion, version) > 0;
      if (hasNewVersion) {
        await Jiffy.setLocale('zh_cn');
        if (context.mounted) {
          unawaited(MBottomSheet.show(context, (ctx) => MBottomSheet(child: _buildUpgradeWidget(ctx, releaseData))));
        }
      } else {
        if (!autoCheck && context.mounted) {
          '没有检测到更新'.toast();
        }
      }
    } catch (e, s) {
      e.$error(stackTrace: s);
    }
  }

  static List<int> _parseVersionSegments(String version) {
    return RegExp(r'\d+').allMatches(version).map((match) => int.parse(match.group(0)!)).toList();
  }

  static int _compareVersions(List<int> lhs, List<int> rhs) {
    final length = lhs.length > rhs.length ? lhs.length : rhs.length;
    for (var i = 0; i < length; i++) {
      final left = i < lhs.length ? lhs[i] : 0;
      final right = i < rhs.length ? rhs[i] : 0;
      if (left != right) {
        return left.compareTo(right);
      }
    }
    return 0;
  }

  static List<Map<String, dynamic>> _filterAssetsForPlatform(List<Map<String, dynamic>> assets) {
    final filtered = assets.where((item) {
      final name = (item['name'] as String).toLowerCase();
      if (Platform.isMacOS) {
        return name.contains('macos');
      }
      if (Platform.isWindows) {
        return name.contains('windows');
      }
      if (Platform.isLinux) {
        return name.contains('linux');
      }
      if (Platform.isAndroid) {
        return name.contains('app');
      }
      if (Platform.isIOS) {
        return name.contains('ios');
      }
      return false;
    }).toList();
    return filtered.isNotEmpty ? filtered : assets;
  }

  static const _kArchLabels = ['arm64-v8a', 'armeabi-v7a', 'x86_64', 'universal', 'win32'];

  static String _parseArchLabel(String fileName) {
    return _kArchLabels.firstWhere((arch) => fileName.contains(arch), orElse: () => 'universal');
  }

  static Widget _buildDownloadItem(BuildContext context, Map<String, dynamic> item, {required ThemeData theme}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name']),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Text(
                    _parseArchLabel(item['name']),
                    style: theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => item['browser_download_url'].toString().launchAppAndCopy(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120.0, 36.0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
              textStyle: const TextStyle(fontSize: 12.0),
            ),
            icon: const Icon(Icons.download_rounded, size: 16.0),
            label: Text('${(item['size'] / 1024 / 1024).toStringAsFixed(2)}MB'),
          ),
        ],
      ),
    );
  }

  static Widget _buildVersionHeader(BuildContext context, Map<String, dynamic> release, ThemeData theme) {
    final jiffy = Jiffy.parse(release['published_at'])..add(hours: 8);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                color: theme.colorScheme.error,
              ),
              child: Text(
                'New ${release["tag_name"]}',
                style: theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onError),
              ),
            ),
            const Gap(4),
            Text('发布于 ${jiffy.yMMMMEEEEdjm}', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  static Widget _buildActionButtons(BuildContext context, Map<String, dynamic> release, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              MyHive.db.put(HiveDBKey.ignoreUpdateVersion, release['tag_name']);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0.0, 36.0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
              backgroundColor: theme.colorScheme.errorContainer,
            ),
            child: Text('下次一定', style: TextStyle(color: theme.colorScheme.onErrorContainer)),
          ),
          const Gap(12),
          ElevatedButton(
            onPressed: () => release['html_url'].toString().launchAppAndCopy(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0.0, 36.0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
            ),
            child: const Text('前往下载'),
          ),
        ],
      ),
    );
  }

  static Widget _buildUpgradeWidget(BuildContext context, Map<String, dynamic> release) {
    return _UpgradeDialog(release: release);
  }
}

class _UpgradeDialog extends StatefulWidget {
  const _UpgradeDialog({required this.release});

  final Map<String, dynamic> release;

  @override
  State<_UpgradeDialog> createState() => _UpgradeDialogState();
}

class _UpgradeDialogState extends State<_UpgradeDialog> {
  bool _filterByPlatform = true;

  List<Map<String, dynamic>> get _filteredAssets {
    final allAssets = (widget.release['assets'] as List).cast<Map<String, dynamic>>();
    if (!_filterByPlatform) {
      return allAssets;
    }
    return UpdateService._filterAssetsForPlatform(allAssets);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assets = _filteredAssets;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                const SliverPinnedAppBar(title: '发现新版本，嘿嘿嘿...'),
                UpdateService._buildVersionHeader(context, widget.release, theme),
                const SliverToBoxAdapter(child: Gap(16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: CheckboxListTile(
                      title: const Text('仅显示当前平台'),
                      value: _filterByPlatform,
                      onChanged: (value) => setState(() => _filterByPlatform = value ?? true),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Gap(8)),
                SliverList.separated(
                  itemBuilder: (context, index) =>
                      UpdateService._buildDownloadItem(context, assets[index], theme: theme),
                  itemCount: assets.length,
                  separatorBuilder: (_, __) =>
                      const Divider(thickness: 0.0, height: 1.0, indent: 24.0, endIndent: 24.0),
                ),
              ],
            ),
          ),
          const Divider(thickness: 0.0, height: 1.0),
          UpdateService._buildActionButtons(context, widget.release, theme),
        ],
      ),
    );
  }
}
