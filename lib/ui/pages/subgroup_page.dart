import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/season_gallery.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/providers/subgroup_model.dart';
import 'package:mikan_flutter/providers/subscribed_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
          final SubgroupModel subgroupModel =
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
                      distance: Sz.statusBarHeight + 42.0,
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
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          ),
        if (galleries.isSafeNotEmpty)
          ...List.generate(galleries.length, (index) {
            final SeasonGallery gallery = galleries[index];
            return <Widget>[
              _buildYearSeasonSection(gallery.title),
              BangumiSliverGridFragment(
                flag: gallery.title,
                padding: galleries.length - 1 == index
                    ? EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 16.0,
                        bottom: 16.0,
                      )
                    : EdgeInsets.all(16.0),
                bangumis: gallery.bangumis,
                handleSubscribe: (bangumi, flag) {
                  context.read<SubscribedModel>().subscribeBangumi(
                    bangumi.id,
                    bangumi.subscribed,
                    onSuccess: () {
                      bangumi.subscribed = !bangumi.subscribed;
                    },
                    onError: (msg) {
                      "订阅失败：$msg".toast();
                    },
                  );
                },
              ),
            ];
          }).expand((element) => element),
      ],
    );
  }

  Widget _buildYearSeasonSection(final String section) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: 8.0,
        ),
        child: Text(
          section,
          style: TextStyle(
            fontSize: 18,
            height: 1.25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(final ThemeData theme) {
    return Selector<SubgroupModel, bool>(
      selector: (_, model) => model.hasScrolled,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, hasScrolled, __) {
        return SliverPinnedToBoxAdapter(
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: hasScrolled
                  ? theme.backgroundColor
                  : theme.scaffoldBackgroundColor,
              borderRadius: scrollHeaderBorderRadius(hasScrolled),
              boxShadow: scrollHeaderBoxShadow(hasScrolled),
            ),
            padding: edge16Header(),
            duration: dur240,
            child: Row(
              children: <Widget>[
                Text(
                  subgroup.name,
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
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
