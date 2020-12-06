import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/providers/view_models/settings_model.dart';
import 'package:mikan_flutter/ui/fragments/theme_panel_fragment.dart';
import 'package:mikan_flutter/widget/common_widgets.dart';
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
        return Scaffold(
          body: NotificationListener(
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
              slivers: [
                _buildHeader(theme),
                _buildThemeSection(theme),
                _buildThemeList(),
                CommonWidgets.sliverBottomSpace,
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

  Widget _buildThemeSection(final ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
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
              top: 16.0 + Sz.statusBarHeight,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            duration: Duration(milliseconds: 240),
            child: Row(
              children: <Widget>[
                Text(
                  "我的",
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
