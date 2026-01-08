import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../features/home/providers/index_provider.dart';
import '../../../features/home/ui/fragments/index.dart' show showSettingsPanel;
import '../../../mikan_routes.dart';
import '../../../res/assets.gen.dart';
import '../../../topvars.dart';
import '../../internal/async_value_extensions.dart';
import '../../internal/extension.dart';
import '../../internal/hive.dart';
import '../../internal/image_provider.dart';
import '../../services/update_service.dart';
import '../../widgets/bottom_sheet.dart';
import '../../widgets/ripple_tap.dart';
import '../../widgets/sliver_pinned_header.dart';
import 'card_setting.dart';
import 'donate.dart';
import 'select_mirror.dart';
import 'select_tablet_mode.dart';
import 'theme_color.dart';

@immutable
class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  String _cacheSize = '';
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    final size = await MyHive.getFormatCacheSize();
    if (mounted) {
      setState(() {
        _cacheSize = size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SettingsHeader(),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildSection(theme, '界面'),
              _buildThemeMode(theme),
              _buildThemeColor(context, theme),
              _buildFontManager(context, theme),
              _buildCardStyle(context, theme),
              _buildCardRatio(context, theme),
              _buildCardWidth(context, theme),
              _buildTabletMode(context, theme),
              _buildSection(theme, '更多'),
              _buildMirror(context, theme),
              _buildDonate(context, theme),
              _buildLicense(context, theme),
              _buildPrivacyPolicy(context, theme),
              _buildClearCache(context, theme),
              _buildCheckUpdate(context, theme),
              gapH24WithNavBarHeight(context),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Text(title, style: theme.textTheme.titleLarge),
    );
  }

  Widget _buildFontManager(BuildContext context, ThemeData theme) {
    return RippleTap(
      onTap: () {
        _showFontManageModal(context);
      },
      child: Container(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Expanded(child: Text('字体管理', style: theme.textTheme.titleMedium)),
            ValueListenableBuilder(
              valueListenable: MyHive.settings.listenable(keys: [SettingsHiveKey.fontFamily]),
              builder: (context, _, child) {
                return Text(MyHive.getFontFamily()?.key ?? '默认', style: theme.textTheme.bodyMedium);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMirror(BuildContext context, ThemeData theme) {
    return RippleTap(
      onTap: () {
        MBottomSheet.show(context, (context) => const MBottomSheet(child: SelectMirror()));
      },
      child: Container(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Expanded(child: Text('镜像地址', style: theme.textTheme.titleMedium)),
            ValueListenableBuilder(
              valueListenable: MyHive.settings.listenable(keys: [SettingsHiveKey.mirrorUrl]),
              builder: (context, _, child) {
                return Text(Uri.parse(MyHive.getMirrorUrl()).host, style: theme.textTheme.bodyMedium);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardRatio(BuildContext context, ThemeData theme) {
    return RippleTap(
      onTap: () {
        Navigator.pop(context);
        MBottomSheet.show(
          context,
          barrierColor: Colors.transparent,
          (context) => const MBottomSheet(height: 200.0, child: CardRatio()),
        );
      },
      child: Container(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Expanded(child: Text('卡片比例', style: theme.textTheme.titleMedium)),
            ValueListenableBuilder(
              valueListenable: MyHive.settings.listenable(keys: [SettingsHiveKey.cardRatio]),
              builder: (context, _, child) {
                return Text(MyHive.getCardRatio().toStringAsFixed(2), style: theme.textTheme.bodyMedium);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWidth(BuildContext context, ThemeData theme) {
    return RippleTap(
      onTap: () {
        Navigator.pop(context);
        MBottomSheet.show(
          context,
          barrierColor: Colors.transparent,
          (context) => const MBottomSheet(height: 200.0, child: CardWidth()),
        );
      },
      child: Container(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Expanded(child: Text('卡片宽度', style: theme.textTheme.titleMedium)),
            ValueListenableBuilder(
              valueListenable: MyHive.settings.listenable(keys: [SettingsHiveKey.cardWidth]),
              builder: (context, _, child) {
                return Text(MyHive.getCardWidth().toStringAsFixed(0), style: theme.textTheme.bodyMedium);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStyle(BuildContext context, ThemeData theme) {
    return RippleTap(
      onTap: () {
        Navigator.pop(context);
        MBottomSheet.show(
          context,
          barrierColor: Colors.transparent,
          (context) => const MBottomSheet(height: 200.0, child: CardStyle()),
        );
      },
      child: Container(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Expanded(child: Text('卡片样式', style: theme.textTheme.titleMedium)),
            ValueListenableBuilder(
              valueListenable: MyHive.settings.listenable(keys: [SettingsHiveKey.cardStyle]),
              builder: (context, _, child) {
                return Text('样式${MyHive.getCardStyle()}', style: theme.textTheme.bodyMedium);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletMode(BuildContext context, ThemeData theme) {
    return RippleTap(
      onTap: () {
        MBottomSheet.show(context, (context) => const MBottomSheet(child: SelectTabletMode()));
      },
      child: Container(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Expanded(child: Text('平板模式', style: theme.textTheme.titleMedium)),
            ValueListenableBuilder(
              valueListenable: MyHive.settings.listenable(keys: [SettingsHiveKey.tabletMode]),
              builder: (context, _, child) {
                return Text(MyHive.getTabletMode().label, style: theme.textTheme.bodyMedium);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeMode(ThemeData theme) {
    final colors = theme.colorScheme;
    final selectedStyle = IconButton.styleFrom(
      foregroundColor: colors.primary,
      backgroundColor: colors.surfaceContainerHighest,
      disabledForegroundColor: colors.onSurface.withValues(alpha: 0.38),
      disabledBackgroundColor: colors.onSurface.withValues(alpha: 0.12),
      hoverColor: colors.primary.withValues(alpha: 0.08),
      focusColor: colors.primary.withValues(alpha: 0.12),
      highlightColor: colors.primary.withValues(alpha: 0.12),
    );
    return Container(
      height: 50.0,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(child: Text('主题模式', style: theme.textTheme.titleMedium)),
          Transform.translate(
            offset: const Offset(8.0, 0.0),
            child: ValueListenableBuilder(
              valueListenable: MyHive.settings.listenable(keys: [SettingsHiveKey.themeMode]),
              builder: (context, _, child) {
                final themeMode = MyHive.getThemeMode();
                return Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        MyHive.setThemeMode(ThemeMode.system);
                      },
                      style: themeMode == ThemeMode.system ? selectedStyle : null,
                      icon: const Icon(Icons.auto_awesome_rounded),
                    ),
                    IconButton(
                      onPressed: () {
                        MyHive.setThemeMode(ThemeMode.light);
                      },
                      style: themeMode == ThemeMode.light ? selectedStyle : null,
                      icon: const Icon(Icons.light_mode_rounded),
                    ),
                    IconButton(
                      onPressed: () {
                        MyHive.setThemeMode(ThemeMode.dark);
                      },
                      style: themeMode == ThemeMode.dark ? selectedStyle : null,
                      icon: const Icon(Icons.dark_mode_rounded),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicense(BuildContext context, ThemeData theme) {
    return RippleTap(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.license.name);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        height: 50.0,
        child: Row(
          children: [
            Expanded(child: Text('开源协议', style: theme.textTheme.titleMedium)),
            const Icon(Icons.east_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildDonate(BuildContext context, ThemeData theme) {
    return RippleTap(
      onTap: () {
        MBottomSheet.show(context, (context) => const MBottomSheet(child: Donate()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        height: 50.0,
        child: Row(
          children: [
            Expanded(child: Text('支持一下', style: theme.textTheme.titleMedium)),
            const Icon(Icons.thumb_up_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildClearCache(BuildContext context, ThemeData theme) {
    return RippleTap(
      onTap: () async {
        final cleared = await _showClearCacheModal(context, theme);
        if (cleared ?? false) {
          // ignore: unawaited_futures
          _loadCacheSize();
        }
      },
      child: Container(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Expanded(child: Text('清除缓存', style: theme.textTheme.titleMedium)),
            Text(_cacheSize, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicy(BuildContext context, ThemeData theme) {
    return RippleTap(
      onTap: () {
        launchUrlString('https://github.com/iota9star/mikan_flutter/blob/master/PrivacyPolicy.md');
      },
      child: Container(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Expanded(child: Text('隐私政策', style: theme.textTheme.titleMedium)),
            const Icon(Icons.east_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckUpdate(BuildContext context, ThemeData theme) {
    return RippleTap(
      onTap: () async {
        setState(() {
          _checkingUpdate = true;
        });
        await UpdateService.checkAppVersion(false);
        if (mounted) {
          setState(() {
            _checkingUpdate = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        height: 50.0,
        child: Row(
          children: [
            Expanded(child: Text('检查更新', style: theme.textTheme.titleMedium)),
            if (_checkingUpdate)
              const ExpressiveLoadingIndicator(constraints: BoxConstraints.tightFor(width: 24, height: 24))
            else
              const SizedBox(),
          ],
        ),
      ),
    );
  }

  void _showFontManageModal(BuildContext context) {
    Navigator.pushNamed(context, Routes.fonts.name);
  }

  Future<bool?> _showClearCacheModal(BuildContext context, ThemeData theme) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('请注意'),
          content: const Text('确认要清除缓存吗？缓存主要来自于番组封面，清除后将重新下载'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                MyHive.clearCache().then((_) {
                  '清除成功'.toast();
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                });
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeColor(BuildContext context, ThemeData theme) {
    return RippleTap(
      onTap: () {
        MBottomSheet.show(context, (context) => const MBottomSheet(child: ThemeColorPanel()));
      },
      child: Container(
        height: 50.0,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            Expanded(child: Text('主题色', style: theme.textTheme.titleMedium)),
            ValueListenableBuilder(
              valueListenable: MyHive.settings.listenable(
                keys: [SettingsHiveKey.colorSeed, SettingsHiveKey.dynamicColor],
              ),
              builder: (context, _, child) {
                final useDynamic = MyHive.dynamicColorEnabled();
                if (useDynamic) {
                  return Text('跟随系统', style: theme.textTheme.bodyMedium);
                }
                final colorSeed = MyHive.getColorSeed();
                return Transform.translate(
                  offset: const Offset(8.0, 0.0),
                  child: IconButton(
                    onPressed: () {
                      MBottomSheet.show(context, (context) => const MBottomSheet(child: ThemeColorPanel()));
                    },
                    icon: Icon(Icons.circle_rounded, color: Color(colorSeed)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings Header - 独立组件，只监听user信息
class SettingsHeader extends ConsumerWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用select只监听user字段
    final user = ref.watch(indexProvider.select((s) => s.valueOrNull?.user));
    final hasLogin = user?.hasLogin ?? false;
    final userName = hasLogin ? user!.name : '请登录 👉';
    final avatar = user?.avatar;

    return SliverPinnedAppBar(
      title: 'Hi, $userName',
      leading: UserAvatar(avatar: avatar),
      startPadding: 16.0,
      endPadding: 8.0,
      minExtent: 64.0,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.login.name);
          },
          icon: hasLogin ? const Icon(Icons.logout_rounded) : const Icon(Icons.login_rounded),
        ),
      ],
    );
  }
}

/// 用户头像组件 - 独立组件，不需要监听
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.avatar});

  final String? avatar;

  @override
  Widget build(BuildContext context) {
    final avatarValue = avatar;
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(24.0)),
      child: avatarValue != null
          ? Image(
              image: CacheImage(avatarValue),
              width: 36.0,
              height: 36.0,
              loadingBuilder: (_, child, event) {
                return event == null ? child : Assets.mikan.image(width: 36.0);
              },
              errorBuilder: (_, __, ___) {
                return Assets.mikan.image(width: 36.0);
              },
            )
          : Assets.mikan.image(width: 36.0),
    );
  }
}

/// 构建头像的辅助函数（保持兼容性）
Widget buildAvatar(String? avatar) {
  return UserAvatar(avatar: avatar);
}

/// 带点击事件的头像组件 - 独立监听user
Widget buildAvatarWithAction(BuildContext context) {
  return RippleTap(
    onTap: () {
      showSettingsPanel(context);
    },
    shape: const CircleBorder(),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer(
        builder: (context, ref, _) {
          // 只监听avatar字段
          final avatar = ref.watch(indexProvider.select((s) => s.valueOrNull?.user?.avatar));
          return UserAvatar(avatar: avatar);
        },
      ),
    ),
  );
}
