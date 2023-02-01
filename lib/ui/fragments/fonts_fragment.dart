import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http_cache_manager.dart';
import 'package:mikan_flutter/model/fonts.dart';
import 'package:mikan_flutter/providers/fonts_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/icon_button.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';
import 'package:mikan_flutter/widget/sliver_pinned_header.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@immutable
class FontsFragment extends StatelessWidget {
  const FontsFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontsModel = Provider.of<FontsModel>(context, listen: false);

    final accentTagStyle = textStyle10WithColor(
      theme.secondary.isDark ? Colors.white : Colors.black,
    );
    final primaryTagStyle = textStyle10WithColor(
      theme.primary.isDark ? Colors.white : Colors.black,
    );
    return Scaffold(
      body: CustomScrollView(
        controller: ModalScrollController.of(context),
        slivers: [
          _buildHeader(context, theme, fontsModel),
          _buildList(
            context,
            theme,
            primaryTagStyle,
            accentTagStyle,
            fontsModel,
          ),
          sliverSizedBoxH24WithNavBarHeight,
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ThemeData theme,
    TextStyle primaryTagStyle,
    TextStyle accentTagStyle,
    FontsModel model,
  ) {
    return SliverPadding(
      padding: edgeH16,
      sliver: Selector<FontsModel, List<Font>>(
        shouldRebuild: (pre, next) => pre.ne(next),
        selector: (_, model) => model.fonts,
        builder: (_, fonts, __) {
          if (model.fonts.isEmpty) {
            return centerLoading;
          }
          return SliverWaterfallFlow(
            gridDelegate:
                const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, index) {
                final Font font = fonts[index];
                return _buildFontItem(
                  theme,
                  primaryTagStyle,
                  accentTagStyle,
                  model,
                  font,
                );
              },
              childCount: fonts.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    FontsModel model,
  ) {
    final it = ColorTween(
      begin: theme.colorScheme.background,
      end: theme.scaffoldBackgroundColor,
    );
    return StackSliverPinnedHeader(
      maxExtent: 136.0,
      minExtent: 60.0,
      childrenBuilder: (context, ratio) {
        final ic = it.transform(ratio);
        final titleRight = ratio * 56.0;
        return [
          Positioned(
            left: 0,
            top: 12.0,
            child: CircleBackButton(color: ic),
          ),
          Positioned(
            right: 0,
            top: 12.0,
            child: Tooltip(
              message: '重置默认字体',
              child: SmallCircleButton(
                color: ic,
                icon: Icons.restart_alt_rounded,
                onTap: () {
                  model.resetDefaultFont();
                },
              ),
            ),
          ),
          Positioned(
            top: 78.0 * (1 - ratio) + 18.0,
            left: titleRight,
            right: titleRight,
            child: Text(
              '字体管理',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24.0 - (ratio * 4.0),
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ];
      },
    );
  }

  Widget _buildFontItem(
    ThemeData theme,
    TextStyle primaryTagStyle,
    TextStyle accentTagStyle,
    FontsModel model,
    Font font,
  ) {
    return ScalableRippleTap(
      onTap: () {
        model.enableFont(font);
      },
      color: theme.colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  font.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle18B,
                ),
                sizedBoxW12,
                ScalableRippleTap(
                  onTap: () {},
                  color: theme.primary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 1.0,
                    ),
                    child: Text(
                      "${font.files.length}个字体",
                      style: primaryTagStyle,
                    ),
                  ),
                ),
                sizedBoxW4,
                ScalableRippleTap(
                  onTap: () {
                    font.official.launchAppAndCopy();
                  },
                  color: theme.secondary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 1.0,
                    ),
                    child: Text(
                      "官网",
                      style: primaryTagStyle,
                    ),
                  ),
                ),
                sizedBoxW4,
                ScalableRippleTap(
                  onTap: () {
                    font.license.url.launchAppAndCopy();
                  },
                  color: theme.secondary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 1.0,
                    ),
                    child: Text(
                      font.license.name,
                      style: accentTagStyle,
                    ),
                  ),
                ),
                spacer,
                _buildLoadingOrChecked(theme, model, font)
              ],
            ),
            sizedBoxH8,
            Text(
              font.desc,
              style: textStyle14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOrChecked(
    ThemeData theme,
    FontsModel model,
    Font font,
  ) {
    return Selector<FontsModel, ProgressChunkEvent?>(
      selector: (_, model) => model.fontProgress[font.id],
      shouldRebuild: (pre, next) => pre?.progress != next?.progress,
      builder: (_, event, __) {
        if (event == null) {
          return sizedBox;
        }
        if (event.percent == 1) {
          if (model.enableFontFamily == font.id) {
            return Icon(
              Icons.task_alt_rounded,
              color: theme.secondary,
              size: 24.0,
            );
          } else {
            return sizedBox;
          }
        }

        return SizedBox(
          width: 16.0,
          height: 16.0,
          child: CircularProgressIndicator(
            value: event.percent,
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation(theme.secondary),
          ),
        );
      },
    );
  }
}
