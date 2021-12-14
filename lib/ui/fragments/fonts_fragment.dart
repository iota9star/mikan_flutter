import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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

@immutable
class FontsFragment extends StatelessWidget {
  const FontsFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final FontsModel fontsModel =
        Provider.of<FontsModel>(context, listen: false);

    final TextStyle accentTagStyle = textStyle10WithColor(
      theme.secondary.isDark ? Colors.white : Colors.black,
    );
    final TextStyle primaryTagStyle = textStyle10WithColor(
      theme.primary.isDark ? Colors.white : Colors.black,
    );
    return Scaffold(
      body: Column(
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
          if (model.fonts.isEmpty) {
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
            minWidth: 32.0,
            color: theme.backgroundColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: circleShape,
            padding: EdgeInsets.zero,
            child: const Icon(
              FluentIcons.chevron_left_24_regular,
              size: 16.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          sizedBoxW12,
          const Expanded(
            child: Text(
              "字体管理",
              style: textStyle24B,
            ),
          ),
          MaterialButton(
            minWidth: 32.0,
            color: theme.backgroundColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: circleShape,
            padding: EdgeInsets.zero,
            child: const Icon(
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
                      theme.primary,
                      theme.primary.withOpacity(0.56),
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
                onTap: () {
                  font.official.launchAppAndCopy();
                },
                margin: edgeR4,
                padding: edgeH4V2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.secondary,
                      theme.secondary.withOpacity(0.56),
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
                onTap: () {
                  font.license.url.launchAppAndCopy();
                },
                margin: edgeR4,
                padding: edgeH4V2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.secondary,
                      theme.secondary.withOpacity(0.56),
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
              _buildLoadingOrChecked(theme, model, font)
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
              FluentIcons.checkmark_starburst_16_filled,
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
