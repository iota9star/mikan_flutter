import 'package:extended_sliver/extended_sliver.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/internal/screen.dart';
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
                style: textStyle20B,
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
          return AnimatedContainer(
            decoration: BoxDecoration(
              color: hasScrolled
                  ? theme.backgroundColor
                  : theme.scaffoldBackgroundColor,
              borderRadius: scrollHeaderBorderRadius(hasScrolled),
              boxShadow: scrollHeaderBoxShadow(hasScrolled),
            ),
            padding: edge16,
            duration: dur240,
            child: _buildHeadSection(),
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
                  style: textStyle20B,
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
      child: Container(
        margin: edgeH16T8,
        decoration: BoxDecoration(
          borderRadius: borderRadius16,
          color: theme.backgroundColor,
        ),
        child: MaterialButton(
          onPressed: () {
            _showFontManageModal(context);
          },
          padding: edgeH16,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius16),
          height: 48.0,
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
    );
  }

  Widget _buildLicense(final BuildContext context, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        margin: edgeH16,
        decoration: BoxDecoration(
          borderRadius: borderRadius16,
          color: theme.backgroundColor,
        ),
        child: MaterialButton(
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.license.name);
          },
          padding: edgeH16,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius16),
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
              Icon(FluentIcons.chevron_right_24_regular),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearCache(
    BuildContext context,
    SettingsModel model,
    ThemeData theme,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: edgeH16T8,
        decoration: BoxDecoration(
          borderRadius: borderRadius16,
          color: theme.backgroundColor,
        ),
        child: MaterialButton(
          onPressed: () async {
            final cleared = await _showClearCacheModal(context, theme);
            if (cleared == true) {
              model.refreshCacheSize();
            }
          },
          padding: edgeH16,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius16),
          height: 48.0,
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
    );
  }

  Widget _buildPrivacyPolicy(final BuildContext context, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        margin: edgeH16T8,
        decoration: BoxDecoration(
          borderRadius: borderRadius16,
          color: theme.backgroundColor,
        ),
        child: MaterialButton(
          onPressed: () {
            launchUrlString(
                "https://github.com/iota9star/mikan_flutter/blob/master/PrivacyPolicy.md");
          },
          padding: edgeH16,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius16),
          height: 48.0,
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
              Icon(FluentIcons.chevron_right_24_regular),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckUpdate(final BuildContext context, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        margin: edgeH16T8,
        decoration: BoxDecoration(
          borderRadius: borderRadius16,
          color: theme.backgroundColor,
        ),
        child: MaterialButton(
          onPressed: () {
            final HomeModel homeModel =
                Provider.of<HomeModel>(context, listen: false);
            homeModel.checkAppVersion(false);
          },
          padding: edgeH16,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius16),
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
    );
  }

  _showFontManageModal(final BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      topRadius: radius16,
      builder: (context) {
        return const FontsFragment();
      },
    );
  }

  Future<bool?> _showClearCacheModal(
    final BuildContext context,
    final ThemeData theme,
  ) {
    return showCupertinoModalBottomSheet<bool>(
      context: context,
      topRadius: radius16,
      builder: (context) {
        return Material(
          color: theme.backgroundColor,
          child: Container(
            height: 240.0,
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0 + Screen.navBarHeight,
              top: 16.0,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      FluentIcons.warning_24_regular,
                      size: 36.0,
                      color: theme.secondary,
                    ),
                    sizedBoxW8,
                    const Expanded(
                      child: Text(
                        "请注意",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle20B,
                      ),
                    ),
                  ],
                ),
                sizedBoxH12,
                Expanded(
                  child: PlaceholderText(
                    "确认要清除缓存吗？缓存主要来自于{番组封面}，清除后将{重新}下载",
                    style: textStyle15B500,
                    onMatched: (pos, matched) {
                      if (pos == 1) {
                        return TextSpan(
                          text: matched.group(1),
                          style: textStyle15B500.copyWith(
                            color: theme.secondary,
                          ),
                        );
                      }
                      return TextSpan(
                        text: matched.group(1),
                        style: textStyle15B500.copyWith(
                          color: theme.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("取消"),
                      ),
                    ),
                    sizedBoxW16,
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Store.clearCache().whenComplete(() {
                            Navigator.pop(context, true);
                          });
                        },
                        child: const Text("确定"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
