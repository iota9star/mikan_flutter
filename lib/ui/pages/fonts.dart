import 'package:easy_refresh/easy_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

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
class Fonts extends StatelessWidget {
  const Fonts({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontsModel = Provider.of<FontsModel>(context, listen: false);
    final style1 = theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onTertiaryContainer);
    final style2 = theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onSecondaryContainer);
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
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: Selector<FontsModel, List<Font>>(
                shouldRebuild: (pre, next) => pre.ne(next),
                selector: (_, model) => model.fonts,
                builder: (_, fonts, __) {
                  return SliverWaterfallFlow(
                    gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400.0,
                      mainAxisSpacing: context.margins,
                      crossAxisSpacing: context.margins,
                    ),
                    delegate: SliverChildBuilderDelegate((_, index) {
                      final font = fonts[index];
                      return _buildFontItem(theme, style1, style2, fontsModel, font);
                    }, childCount: fonts.length),
                  );
                },
              ),
            ),
            sliverGapH24WithNavBarHeight(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFontItem(ThemeData theme, TextStyle style1, TextStyle style2, FontsModel model, Font font) {
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
                const Gap(4),
                _buildLoadingOrChecked(theme, model, font),
              ],
            ),
            const Gap(4),
            Row(
              children: [
                RippleTap(
                  onTap: () {},
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    child: Text('${font.files.length}个字体', style: style1),
                  ),
                ),
                const Gap(4),
                RippleTap(
                  onTap: () {
                    font.official.launchAppAndCopy();
                  },
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    child: Text('官网', style: style2),
                  ),
                ),
                const Gap(4),
                RippleTap(
                  onTap: () {
                    font.license.url.launchAppAndCopy();
                  },
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    child: Text(font.license.name, style: style2),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Text(font.desc, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOrChecked(ThemeData theme, FontsModel model, Font font) {
    return Selector<FontsModel, ProgressChunkEvent?>(
      selector: (_, model) => model.fontProgress[font.id],
      shouldRebuild: (pre, next) => pre?.progress != next?.progress,
      builder: (_, event, __) {
        if (event == null) {
          return const SizedBox();
        }
        if (event.percent == 1.0) {
          if (model.usedFontFamilyId == font.id) {
            return const Icon(Icons.check_circle_outline_rounded);
          } else {
            return const SizedBox();
          }
        }
        return const ExpressiveLoadingIndicator(
          constraints: BoxConstraints.tightFor(width: 16, height: 16),
        );
      },
    );
  }
}
