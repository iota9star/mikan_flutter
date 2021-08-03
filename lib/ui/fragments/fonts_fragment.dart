import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http_cache_manager.dart';
import 'package:mikan_flutter/model/fonts.dart';
import 'package:mikan_flutter/providers/fonts_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class FontsFragment extends StatelessWidget {
  const FontsFragment();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final FontsModel fontsModel =
        Provider.of<FontsModel>(context, listen: false);

    final TextStyle accentTagStyle = textStyle10WithColor(
      theme.accentColor.isDark ? Colors.white : Colors.black,
    );
    final TextStyle primaryTagStyle = textStyle10WithColor(
      theme.primaryColor.isDark ? Colors.white : Colors.black,
    );
    return Scaffold(
      body: NotificationListener(
        onNotification: (notification) {
          if (notification is OverscrollIndicatorNotification) {
            notification.disallowGlow();
          } else if (notification is ScrollUpdateNotification) {
            if (notification.depth == 0) {
              final double offset = notification.metrics.pixels;
            }
          }
          return true;
        },
        child: Column(
          children: [
            _buildHeader(context, theme, fontsModel),
            _buildList(
              context,
              theme,
              primaryTagStyle,
              accentTagStyle,
              fontsModel,
            ),
          ],
        ),
      ),
    );
  }

  Expanded _buildList(
    BuildContext context,
    ThemeData theme,
    TextStyle primaryTagStyle,
    TextStyle accentTagStyle,
    FontsModel model,
  ) {
    return Expanded(
      child: Selector<FontsModel, List<Font>>(
        shouldRebuild: (pre, next) => pre.ne(next),
        selector: (_, model) => model.fonts,
        builder: (_, fonts, __) {
          if (model.fonts.length == 0) {
            return centerLoading;
          }
          return GridView.builder(
            controller: ModalScrollController.of(context),
            itemCount: fonts.length,
            padding: edge16,
            itemBuilder: (_, index) {
              final Font font = fonts[index];
              return _buildFontItem(
                theme,
                primaryTagStyle,
                accentTagStyle,
                model,
                font,
              );
            },
            gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              mainAxisExtent: 102.0,
            ),
          );
        },
      ),
    );
  }

  Padding _buildHeader(
    BuildContext context,
    ThemeData theme,
    FontsModel model,
  ) {
    return Padding(
      padding: edge16,
      child: Row(
        children: [
          MaterialButton(
            minWidth: 28.0,
            color: theme.backgroundColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: circleShape,
            padding: EdgeInsets.zero,
            child: Icon(
              FluentIcons.chevron_left_24_regular,
              size: 16.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          sizedBoxW12,
          Expanded(
            child: Text(
              "字体管理",
              style: textStyle24B,
            ),
          ),
          MaterialButton(
            minWidth: 28.0,
            color: theme.backgroundColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: circleShape,
            padding: EdgeInsets.zero,
            child: Icon(
              FluentIcons.arrow_reset_24_regular,
              size: 16.0,
            ),
            onPressed: () {
              model.resetDefaultFont();
            },
          ),
        ],
      ),
    );
  }

  TapScaleContainer _buildFontItem(
    ThemeData theme,
    TextStyle primaryTagStyle,
    TextStyle accentTagStyle,
    FontsModel model,
    Font font,
  ) {
    return TapScaleContainer(
      onTap: () {
        model.enableFont(font);
      },
      decoration: BoxDecoration(
        borderRadius: borderRadius16,
        gradient: LinearGradient(
          colors: [
            theme.backgroundColor.withOpacity(0.64),
            theme.backgroundColor.withOpacity(0.87),
            theme.backgroundColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.loose,
        children: [
          Selector<FontsModel, ProgressChunkEvent?>(
            selector: (_, model) => model.fontProgress[font.id],
            shouldRebuild: (pre, next) => pre?.progress != next?.progress,
            builder: (_, event, __) {
              if (event == null) {
                return sizedBox;
              }
              return Positioned.fill(
                child: ClipRRect(
                  child: LinearProgressIndicator(
                    value: event.percent,
                    minHeight: double.infinity,
                    backgroundColor: theme.accentColor.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation(
                      theme.accentColor.withOpacity(0.1),
                    ),
                  ),
                  borderRadius: borderRadius16,
                ),
              );
            },
          ),
          Positioned(
            left: 16.0,
            top: 16.0,
            right: 16.0,
            bottom: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      font.name,
                      style: textStyle18B,
                    ),
                    sizedBoxW12,
                    TapScaleContainer(
                      onTap: () {},
                      margin: edgeR4,
                      padding: edgeH4V2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.56),
                          ],
                        ),
                        borderRadius: borderRadius2,
                      ),
                      child: Text(
                        "${font.files.length}个字体",
                        style: primaryTagStyle,
                      ),
                    ),
                    TapScaleContainer(
                      onTap: () {},
                      margin: edgeR4,
                      padding: edgeH4V2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.accentColor,
                            theme.accentColor.withOpacity(0.56),
                          ],
                        ),
                        borderRadius: borderRadius2,
                      ),
                      child: Text(
                        "官网",
                        style: primaryTagStyle,
                      ),
                    ),
                    TapScaleContainer(
                      onTap: () {},
                      margin: edgeR4,
                      padding: edgeH4V2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.accentColor,
                            theme.accentColor.withOpacity(0.56),
                          ],
                        ),
                        borderRadius: borderRadius2,
                      ),
                      child: Text(
                        font.license.name,
                        style: accentTagStyle,
                      ),
                    ),
                    spacer,
                    if (model.enableFontFamily == font.id)
                      Icon(
                        FluentIcons.checkmark_starburst_16_filled,
                        color: theme.accentColor,
                        size: 24.0,
                      )
                  ],
                ),
                sizedBoxH8,
                Tooltip(
                  message: font.desc,
                  padding: edgeH12V8,
                  margin: edgeH16,
                  child: Text(
                    font.desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
