import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../internal/delegate.dart';
import '../../internal/extension.dart';
import '../../internal/http_cache_manager.dart';
import '../../internal/kit.dart';
import '../../model/fonts.dart';
import '../../providers/fonts_model.dart';
import '../../topvars.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/scalable_tap.dart';
import '../../widget/sliver_pinned_header.dart';

@FFRoute(name: '/fonts')
class FontsFragment extends StatelessWidget {
  const FontsFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontsModel = Provider.of<FontsModel>(context, listen: false);
    final accentTagStyle = theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
    );
    final primaryTagStyle = accentTagStyle.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Scaffold(
      body: EasyRefresh(
        onRefresh: fontsModel.load,
        header: defaultHeader,
        refreshOnStart: true,
        child: CustomScrollView(
          slivers: [
            SliverPinnedAppBar(
              title: '字体管理',
              actions: [
                Tooltip(
                  message: '重置默认字体',
                  child: IconButton(
                    icon: const Icon(Icons.restart_alt_rounded),
                    onPressed: fontsModel.resetDefaultFont,
                  ),
                )
              ],
            ),
            _buildList(
              context,
              theme,
              primaryTagStyle,
              accentTagStyle,
              fontsModel,
            ),
            sliverSizedBoxH24WithNavBarHeight(context),
          ],
        ),
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
      padding: edgeH24,
      sliver: Selector<FontsModel, List<Font>>(
        shouldRebuild: (pre, next) => pre.ne(next),
        selector: (_, model) => model.fonts,
        builder: (_, fonts, __) {
          return SliverWaterfallFlow(
            gridDelegate: SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              mainAxisSpacing: context.margins,
              crossAxisSpacing: context.margins,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, index) {
                final font = fonts[index];
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

  Widget _buildFontItem(
    ThemeData theme,
    TextStyle primaryTagStyle,
    TextStyle accentTagStyle,
    FontsModel model,
    Font font,
  ) {
    return ScalableCard(
      onTap: () {
        model.enableFont(font);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    font.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                sizedBoxW4,
                _buildLoadingOrChecked(theme, model, font)
              ],
            ),
            sizedBoxH4,
            Row(
              children: [
                RippleTap(
                  onTap: () {},
                  color: theme.primary,
                  borderRadius: borderRadius4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    child: Text(
                      '${font.files.length}个字体',
                      style: primaryTagStyle,
                    ),
                  ),
                ),
                sizedBoxW4,
                RippleTap(
                  onTap: () {
                    font.official.launchAppAndCopy();
                  },
                  color: theme.secondary,
                  borderRadius: borderRadius4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    child: Text(
                      '官网',
                      style: primaryTagStyle,
                    ),
                  ),
                ),
                sizedBoxW4,
                RippleTap(
                  onTap: () {
                    font.license.url.launchAppAndCopy();
                  },
                  color: theme.secondary,
                  borderRadius: borderRadius4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    child: Text(
                      font.license.name,
                      style: accentTagStyle,
                    ),
                  ),
                ),
              ],
            ),
            sizedBoxH8,
            Text(
              font.desc,
              style: theme.textTheme.bodySmall,
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
        if (event.percent == 1.0) {
          if (model.usedFontFamilyId == font.id) {
            return const Icon(Icons.check_circle_outline_rounded);
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
          ),
        );
      },
    );
  }
}
