import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/model/fonts.dart';
import 'package:mikan_flutter/providers/fonts_model.dart';
import 'package:mikan_flutter/providers/theme_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class FontsFragment extends StatelessWidget {
  const FontsFragment();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThemeModel themeModel = Provider.of(context, listen: false);
    final TextStyle accentTagStyle = textStyle10WithColor(
      theme.accentColor.isDark ? Colors.white : Colors.black,
    );
    final TextStyle primaryTagStyle = textStyle10WithColor(
      theme.primaryColor.isDark ? Colors.white : Colors.black,
    );
    return ChangeNotifierProvider(
      create: (_) => FontsModel(themeModel),
      child: Builder(builder: (context) {
        final model = Provider.of<FontsModel>(context, listen: false);
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
                Padding(
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
                    ],
                  ),
                ),
                Expanded(
                  child: Selector<FontsModel, List<Font>>(
                    shouldRebuild: (pre, next) => pre.ne(next),
                    selector: (_, model) => model.fonts,
                    builder: (_, fonts, __) {
                      if (model.fonts.length == 0) {
                        return CupertinoActivityIndicator();
                      }
                      return WaterfallFlow.builder(
                        controller: ModalScrollController.of(context),
                        itemCount: fonts.length,
                        padding: edge16,
                        itemBuilder: (_, index) {
                          final Font font = fonts[index];
                          return TapScaleContainer(
                            onTap: () {
                              model.enableFont(font);
                            },
                            padding: edge16,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      font.name,
                                      style: textStyle16B,
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
                                            theme.primaryColor
                                                .withOpacity(0.56),
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
                                        font.license.name ?? "协议",
                                        style: accentTagStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                sizedBoxH4,
                                Text(
                                  font.desc,
                                  style: textStyle13,
                                ),
                              ],
                            ),
                          );
                        },
                        gridDelegate:
                            const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
                          minCrossAxisExtent: 400.0,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
