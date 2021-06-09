import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/season_gallery.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/providers/op_model.dart';
import 'package:mikan_flutter/providers/subgroup_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliver_tools/sliver_tools.dart';

@FFRoute(
  name: "subgroup",
  routeName: "subgroup",
  argumentImports: [
    "import 'package:mikan_flutter/model/subgroup.dart';",
    "import 'package:flutter/material.dart';",
  ],
)
@immutable
class SubgroupPage extends StatelessWidget {
  final Subgroup subgroup;

  const SubgroupPage({Key? key, required this.subgroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => SubgroupModel(subgroup),
        child: Builder(builder: (context) {
          final subgroupModel =
              Provider.of<SubgroupModel>(context, listen: false);
          return Scaffold(
            body: NotificationListener(
              onNotification: (notification) {
                if (notification is OverscrollIndicatorNotification) {
                  notification.disallowGlow();
                } else if (notification is ScrollUpdateNotification) {
                  if (notification.depth == 0) {
                    final double offset = notification.metrics.pixels;
                    subgroupModel.hasScrolled = offset > 0.0;
                  }
                }
                return true;
              },
              child: Selector<SubgroupModel, List<SeasonGallery>>(
                selector: (_, model) => model.galleries,
                shouldRebuild: (pre, next) => pre.ne(next),
                builder: (context, galleries, __) {
                  return SmartRefresher(
                    controller: subgroupModel.refreshController,
                    header: WaterDropMaterialHeader(
                      backgroundColor: theme.accentColor,
                      color: theme.accentColor.computeLuminance() < 0.5
                          ? Colors.white
                          : Colors.black,
                      distance: Screen.statusBarHeight + 42.0,
                    ),
                    enablePullDown: true,
                    enablePullUp: false,
                    onRefresh: subgroupModel.refresh,
                    child: _buildContentWrapper(
                      context,
                      theme,
                      subgroupModel,
                      galleries,
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContentWrapper(
    final BuildContext context,
    final ThemeData theme,
    final SubgroupModel subgroupModel,
    final List<SeasonGallery> galleries,
  ) {
    return CustomScrollView(
      slivers: [
        _buildHeader(theme),
        if (subgroupModel.loading)
          SliverFillRemaining(
            child: centerLoading,
          ),
        if (galleries.isSafeNotEmpty)
          ...List.generate(galleries.length, (index) {
            final SeasonGallery gallery = galleries[index];
            return MultiSliver(
              pushPinnedChildren: true,
              children: <Widget>[
                _buildYearSeasonSection(theme, gallery.title),
                BangumiSliverGridFragment(
                  flag: gallery.title,
                  padding: edgeHB16T4,
                  bangumis: gallery.bangumis,
                  handleSubscribe: (bangumi, flag) {
                    context.read<OpModel>().subscribeBangumi(
                      bangumi.id,
                      bangumi.subscribed,
                      onSuccess: () {
                        bangumi.subscribed = !bangumi.subscribed;
                        context.read<OpModel>().subscribeChanged(flag);
                      },
                      onError: (msg) {
                        "订阅失败：$msg".toast();
                      },
                    );
                  },
                ),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildYearSeasonSection(final ThemeData theme, final String section) {
    return SliverPinnedToBoxAdapter(
      child: Transform.translate(
        offset: offsetY_1,
        child: Container(
          padding: edgeH16V8,
          color: theme.scaffoldBackgroundColor,
          child: Text(
            section,
            style: textStyle20B,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(final ThemeData theme) {
    return Selector<SubgroupModel, bool>(
      selector: (_, model) => model.hasScrolled,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, hasScrolled, __) {
        return SliverPinnedToBoxAdapter(
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: hasScrolled
                  ? theme.backgroundColor
                  : theme.scaffoldBackgroundColor,
              borderRadius: scrollHeaderBorderRadius(hasScrolled),
              boxShadow: scrollHeaderBoxShadow(hasScrolled),
            ),
            padding: edge16WithStatusBar,
            duration: dur240,
            child: Row(
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    FluentIcons.chevron_left_24_regular,
                    size: 16.0,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minWidth: 36.0,
                  shape: circleShape,
                  color: hasScrolled
                      ? theme.scaffoldBackgroundColor
                      : theme.backgroundColor,
                ),
                sizedBoxW12,
                Expanded(
                  child: Text(
                    subgroup.name,
                    style: textStyle24B,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
