import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/providers/view_models/index_model.dart';
import 'package:mikan_flutter/providers/view_models/settings_model.dart';
import 'package:mikan_flutter/ui/fragments/theme_panel_fragment.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

@immutable
class SettingsFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => SettingsModel(),
      child: Builder(builder: (context) {
        final SettingsModel settingsModel = Provider.of(context, listen: false);
        return Material(
          color: theme.scaffoldBackgroundColor,
          child: NotificationListener(
            onNotification: (notification) {
              if (notification is OverscrollIndicatorNotification) {
                notification.disallowGlow();
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
                _buildThemeSection(),
                _buildThemeList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildThemeList() {
    return SliverToBoxAdapter(
      child: ThemePanelFragment(),
    );
  }

  Widget _buildThemeSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                "主题",
                style: TextStyle(
                  fontSize: 20.0,
                  height: 1.25,
                  fontWeight: FontWeight.bold,
                ),
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
              boxShadow: hasScrolled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.024),
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        spreadRadius: 3.0,
                      ),
                    ]
                  : null,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
            ),
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            duration: Duration(milliseconds: 240),
            child: _buildHeadSection(),
          );
        },
      ),
    );
  }

  Widget _buildHeadSection() {
    return Selector<IndexModel, User>(
      selector: (_, model) => model.user,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, user, __) {
        return MaterialButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.login);
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
              SizedBox(
                width: 16.0,
              ),
              Expanded(
                child: Text(
                  "Hi, ${user?.hasLogin == true ? user.name : "👉 请登录 👈"}",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(User user) {
    return user?.hasLogin == true
        ? ClipOval(
            child: ExtendedImage(
              image: CachedNetworkImageProvider(user.avatar),
              width: 36.0,
              height: 36.0,
              loadStateChanged: (state) {
                switch (state.extendedImageLoadState) {
                  case LoadState.loading:
                  case LoadState.failed:
                    return ExtendedImage.asset(
                      "assets/mikan.png",
                      width: 36.0,
                      height: 36.0,
                    );
                  case LoadState.completed:
                    return null;
                }
                return null;
              },
            ),
          )
        : ExtendedImage.asset(
            "assets/mikan.png",
            width: 36.0,
            height: 36.0,
          );
  }
}
