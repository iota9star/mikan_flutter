import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/providers/home_model.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/providers/settings_model.dart';
import 'package:mikan_flutter/providers/theme_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/fragments/fonts_fragment.dart';
import 'package:mikan_flutter/ui/fragments/theme_panel_fragment.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

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
          child: NotificationListener(
            onNotification: (notification) {
              if (notification is OverscrollIndicatorNotification) {
                notification.disallowIndicator();
              } else if (notification is ScrollUpdateNotification) {
                if (notification.depth == 0) {
                  final double offset = notification.metrics.pixels;
                  settingsModel.hasScrolled = offset > 0.0;
                }
              }
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
                _buildSection("更新"),
                _buildCheckUpdate(context, theme),
                sliverSizedBoxH24,
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
            padding: edgeHT16,
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
    final placeholder = ExtendedImage.asset(
      "assets/mikan.png",
      width: 36.0,
      height: 36.0,
    );
    return user?.hasLogin == true
        ? ClipOval(
            child: ExtendedImage(
              image: CacheImageProvider(user!.avatar ?? ""),
              width: 36.0,
              height: 36.0,
              loadStateChanged: (state) {
                switch (state.extendedImageLoadState) {
                  case LoadState.loading:
                  case LoadState.failed:
                    return placeholder;
                  case LoadState.completed:
                    return null;
                }
              },
            ),
          )
        : placeholder;
  }

  Widget _buildFontManager(final BuildContext context, ThemeData theme) {
    final ThemeModel themeModel =
        Provider.of<ThemeModel>(context, listen: false);
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

  Widget _buildCheckUpdate(final BuildContext context, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        margin: edgeH16,
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
}
