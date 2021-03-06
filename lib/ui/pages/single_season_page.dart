import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/providers/view_models/op_model.dart';
import 'package:mikan_flutter/providers/view_models/season_model.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@FFRoute(
  name: "season",
  routeName: "season",
  argumentImports: [
    "import 'package:mikan_flutter/model/season.dart';",
    "import 'package:flutter/material.dart';",
  ],
)
class SingleSeasonPage extends StatelessWidget {
  final Season season;

  const SingleSeasonPage({Key key, this.season}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => SeasonModel(this.season),
      child: Builder(builder: (context) {
        final SeasonModel seasonModel =
            Provider.of<SeasonModel>(context, listen: false);
        return Scaffold(
          body: NotificationListener(
            onNotification: (notification) {
              if (notification is OverscrollIndicatorNotification) {
                notification.disallowGlow();
              } else if (notification is ScrollUpdateNotification) {
                if (notification.depth == 0) {
                  final double offset = notification.metrics.pixels;
                  seasonModel.hasScrolled = offset > 0.0;
                }
              }
              return true;
            },
            child: Selector<SeasonModel, List<BangumiRow>>(
              selector: (_, model) => model.bangumiRows,
              shouldRebuild: (pre, next) => pre.ne(next),
              builder: (_, bangumiRows, __) {
                return SmartRefresher(
                  controller: seasonModel.refreshController,
                  enablePullUp: false,
                  enablePullDown: true,
                  header: WaterDropMaterialHeader(
                    backgroundColor: theme.accentColor,
                    color: theme.accentColor.computeLuminance() < 0.5
                        ? Colors.white
                        : Colors.black,
                    distance: Sz.statusBarHeight + 42.0,
                  ),
                  onRefresh: seasonModel.refresh,
                  child: CustomScrollView(
                    controller: ModalScrollController.of(context),
                    slivers: [
                      _buildHeader(theme),
                      ...List.generate(bangumiRows.length, (index) {
                        final BangumiRow bangumiRow = bangumiRows[index];
                        return [
                          _buildWeekSection(theme, bangumiRow),
                          BangumiSliverGridFragment(
                            padding: bangumiRows.length - 1 == index
                                ? EdgeInsets.only(
                                    left: 16.0,
                                    right: 16.0,
                                    top: 16.0,
                                    bottom: 16.0 + Sz.navBarHeight,
                                  )
                                : EdgeInsets.all(16.0),
                            bangumis: bangumiRow.bangumis,
                            handleSubscribe: (bangumi, flag) {
                              context.read<OpModel>().subscribeBangumi(
                                bangumi.id,
                                bangumi.subscribed,
                                onSuccess: () {
                                  bangumi.subscribed = !bangumi.subscribed;
                                  context.read<OpModel>().performTap(flag);
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
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(final ThemeData theme) {
    return Selector<SeasonModel, bool>(
      selector: (_, model) => model.hasScrolled,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, hasScrolled, __) {
        return SliverPinnedToBoxAdapter(
          child: AnimatedContainer(
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
              borderRadius: hasScrolled
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    )
                  : null,
            ),
            padding: EdgeInsets.only(
              top: 16.0 + Sz.statusBarHeight,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            duration: Duration(milliseconds: 240),
            child: Text(
              this.season.title,
              style: TextStyle(
                fontSize: 24,
                height: 1.25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekSection(
    final ThemeData theme,
    final BangumiRow bangumiRow,
  ) {
    final simple = [
      if (bangumiRow.updatedNum > 0) "🚀 ${bangumiRow.updatedNum}部",
      if (bangumiRow.subscribedUpdatedNum > 0)
        "💖 ${bangumiRow.subscribedUpdatedNum}部",
      if (bangumiRow.subscribedNum > 0) "❤ ${bangumiRow.subscribedNum}部",
      "🎬 ${bangumiRow.num}部"
    ].join("，");
    final full = [
      if (bangumiRow.updatedNum > 0) "更新${bangumiRow.updatedNum}部",
      if (bangumiRow.subscribedUpdatedNum > 0)
        "订阅更新${bangumiRow.subscribedUpdatedNum}部",
      if (bangumiRow.subscribedNum > 0) "订阅${bangumiRow.subscribedNum}部",
      "共${bangumiRow.num}部"
    ].join("，");

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
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
                bangumiRow.name,
                style: TextStyle(
                  fontSize: 20.0,
                  height: 1.25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Tooltip(
              message: full,
              child: Text(
                simple,
                style: TextStyle(
                  color: theme.textTheme.subtitle1.color,
                  fontSize: 12.0,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
