import 'dart:ui';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/internal/store.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/providers/home_model.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/providers/settings_model.dart';
import 'package:mikan_flutter/providers/theme_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/fragments/fonts_fragment.dart';
import 'package:mikan_flutter/ui/fragments/theme_panel_fragment.dart';
import 'package:mikan_flutter/widget/placeholder_text.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

@immutable
class SettingsFragment extends StatelessWidget {
  const SettingsFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => SettingsModel(),
      child: Builder(builder: (context) {
        final settingsModel =
        Provider.of<SettingsModel>(context, listen: false);
        return Material(
          color: theme.scaffoldBackgroundColor,
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: (ScrollUpdateNotification notification) {
              final double offset = notification.metrics.pixels;
              settingsModel.hasScrolled = offset > 0.0;
              return true;
            },
            child: CustomScrollView(
              shrinkWrap: true,
              controller: ModalScrollController.of(context),
              slivers: [
                _buildHeader(theme),
                _buildSection("主题"),
                _buildThemeList(),
                _buildFontManager(context, theme),
                _buildSection("更多"),
                _buildLicense(context, theme),
                _buildPrivacyPolicy(context, theme),
                _buildClearCache(context, settingsModel, theme),
                _buildCheckUpdate(context, theme),
                sliverSizedBoxH24WithNavBarHeight,
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildThemeList() {
    return const SliverToBoxAdapter(
      child: ThemePanelFragment(),
    );
  }

  Widget _buildSection(final String title) {
    return SliverToBoxAdapter(
      child: Container(
        padding: edge16,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: textStyle18B,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(final ThemeData theme) {
    return SliverPinnedToBoxAdapter(
      child: Selector<SettingsModel, bool>(
        selector: (_, model) => model.hasScrolled,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, hasScrolled, __) {
          return ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 16.0, sigmaX: 16.0),
              child: AnimatedContainer(
                decoration: BoxDecoration(
                  color: (hasScrolled
                          ? theme.backgroundColor
                          : theme.scaffoldBackgroundColor)
                      .withOpacity(0.87),
                ),
                padding: edge16,
                duration: dur240,
                child: _buildHeadSection(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeadSection() {
    return Selector<IndexModel, User?>(
      selector: (_, model) => model.user,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, user, __) {
        return MaterialButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.login.name);
          },
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Row(
            children: [
              _buildAvatar(user),
              sizedBoxW16,
              Expanded(
                child: Text(
                  "Hi, ${user?.hasLogin == true ? user!.name : "👉 请登录 👈"}",
                  style: textStyle18B,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(User? user) {
    final placeholder = Image.asset(
      "assets/mikan.png",
      width: 36.0,
      height: 36.0,
    );
    return user?.hasLogin == true
        ? ClipOval(
      child: Image(
        image: CacheImageProvider(user!.avatar ?? ""),
        width: 36.0,
        height: 36.0,
        loadingBuilder: (_, child, event) {
          return event == null ? child : placeholder;
        },
        errorBuilder: (_, __, ___) {
          return placeholder;
        },
      ),
    )
        : placeholder;
  }

  Widget _buildFontManager(final BuildContext context, ThemeData theme) {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    return SliverToBoxAdapter(
      child: Padding(
        padding: edgeH16T8,
        child: RippleTap(
          color: theme.backgroundColor,
          onTap: () {
            _showFontManageModal(context);
          },
          child: Container(
            height: 48.0,
            padding: edgeH16,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "字体管理",
                    style: textStyle16B500,
                  ),
                ),
                Text(
                  themeModel.themeItem.fontFamilyName ?? "默认",
                  style: textStyle14,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLicense(final BuildContext context, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: edgeH16,
        child: RippleTap(
          color: theme.backgroundColor,
          onTap: () {
            Navigator.of(context).pushNamed(Routes.license.name);
          },
          child: Container(
            padding: edgeH16,
            height: 48.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Expanded(
                  child: Text(
                    "开源协议",
                    style: textStyle16B500,
                    textAlign: TextAlign.left,
                  ),
                ),
                Icon(Icons.east_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearCache(BuildContext context,
      SettingsModel model,
      ThemeData theme,) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: edgeH16T8,
        child: RippleTap(
          color: theme.backgroundColor,
          onTap: () async {
            final cleared = await _showClearCacheModal(context, theme);
            if (cleared == true) {
              model.refreshCacheSize();
            }
          },
          child: Container(
            height: 48.0,
            padding: edgeH16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    "清除缓存",
                    style: textStyle16B500,
                    textAlign: TextAlign.left,
                  ),
                ),
                Selector<SettingsModel, String>(
                  selector: (_, model) => model.formatCacheSize,
                  builder: (context, value, _) {
                    return Text(
                      value,
                      style: theme.textTheme.caption,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicy(final BuildContext context, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: edgeH16T8,
        child: RippleTap(
          color: theme.backgroundColor,
          onTap: () {
            launchUrlString(
                "https://github.com/iota9star/mikan_flutter/blob/master/PrivacyPolicy.md");
          },
          child: Container(
            height: 48.0,
            padding: edgeH16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Expanded(
                  child: Text(
                    "隐私政策",
                    style: textStyle16B500,
                    textAlign: TextAlign.left,
                  ),
                ),
                Icon(Icons.east_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckUpdate(final BuildContext context, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: edgeH16T8,
        child: RippleTap(
          color: theme.backgroundColor,
          onTap: () {
            final HomeModel homeModel =
                Provider.of<HomeModel>(context, listen: false);
            homeModel.checkAppVersion(false);
          },
          child: Container(
            padding: edgeH16,
            height: 48.0,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "检查更新",
                    style: textStyle16B500,
                  ),
                ),
                Selector<HomeModel, bool>(
                  selector: (_, model) => model.checkingUpgrade,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (_, checking, __) {
                    if (checking) {
                      return const CupertinoActivityIndicator();
                    }
                    return sizedBox;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFontManageModal(final BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      topRadius: radius0,
      builder: (context) {
        return const FontsFragment();
      },
    );
  }

  Future<bool?> _showClearCacheModal(final BuildContext context,
      final ThemeData theme,) {
    return showCupertinoModalBottomSheet<bool>(
      context: context,
      topRadius: radius0,
      builder: (context) {
        return Material(
          color: theme.scaffoldBackgroundColor,
          child: SizedBox(
            height: 360.0,
            child: Column(
              children: [
                Container(
                  padding: edge16,
                  color: theme.backgroundColor,
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        size: 36.0,
                        color: theme.secondary,
                      ),
                      sizedBoxW8,
                      const Expanded(
                        child: Text(
                          "请注意",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle18B,
                        ),
                      ),
                    ],
                  ),
                ),
                sizedBoxH12,
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Expanded(
                    child: PlaceholderText(
                      "确认要清除缓存吗？缓存主要来自于{番组封面}，清除后将{重新}下载",
                      style: textStyle14.copyWith(height: 1.5),
                      onMatched: (pos, matched) {
                        if (pos == 1) {
                          return TextSpan(
                            text: matched.group(1),
                            style: TextStyle(
                              color: theme.secondary,
                            ),
                          );
                        }
                        return TextSpan(
                          text: matched.group(1),
                          style: TextStyle(
                            color: theme.primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                spacer,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("取消"),
                        ),
                      ),
                      sizedBoxW16,
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () {
                            Store.clearCache().whenComplete(() {
                              "清除成功".toast();
                              Navigator.pop(context, true);
                            });
                          },
                          child: const Text("确定"),
                        ),
                      ),
                    ],
                  ),
                ),
                sizedBoxH24WithNavBarHeight,
              ],
            ),
          ),
        );
      },
    );
  }
}
