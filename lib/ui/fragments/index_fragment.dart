import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/providers/subscribed_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/components/ova_record_item.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:mikan_flutter/ui/fragments/search_fragment.dart';
import 'package:mikan_flutter/ui/fragments/select_season_fragment.dart';
import 'package:mikan_flutter/ui/fragments/settings_fragment.dart';
import 'package:mikan_flutter/widget/common_widgets.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliver_tools/sliver_tools.dart';

@immutable
class IndexFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final IndexModel indexModel =
        Provider.of<IndexModel>(context, listen: false);
    return Scaffold(
      body: NotificationListener(
        onNotification: (notification) {
          if (notification is OverscrollIndicatorNotification) {
            notification.disallowGlow();
          } else if (notification is ScrollUpdateNotification) {
            if (notification.depth == 0) {
              final double offset = notification.metrics.pixels;
              indexModel.hasScrolled = offset > 0.0;
            }
          }
          return true;
        },
        child: Selector<IndexModel, List<BangumiRow>>(
          selector: (_, model) => model.bangumiRows,
          shouldRebuild: (pre, next) => pre.ne(next),
          builder: (_, bangumiRows, __) {
            if (bangumiRows.isNullOrEmpty && indexModel.seasonLoading) {
              return Center(
                child: CupertinoActivityIndicator(),
              );
            }
            return SmartRefresher(
              controller: indexModel.refreshController,
              enablePullUp: false,
              enablePullDown: true,
              header: WaterDropMaterialHeader(
                backgroundColor: theme.accentColor,
                color: theme.accentColor.computeLuminance() < 0.5
                    ? Colors.white
                    : Colors.black,
                distance: Sz.statusBarHeight + 42.0,
              ),
              onRefresh: indexModel.refresh,
              child: CustomScrollView(
                slivers: [
                  _buildHeader(context, theme),
                  _buildCarousels(theme),
                  _buildOVASection(),
                  _buildOVAList(theme),
                  ...List.generate(
                    bangumiRows.length,
                    (index) {
                      final BangumiRow bangumiRow = bangumiRows[index];
                      return MultiSliver(
                        pushPinnedChildren: true,
                        children: [
                          _buildWeekSection(theme, bangumiRow),
                          BangumiSliverGridFragment(
                            padding: edgeHB16T4,
                            bangumis: bangumiRow.bangumis,
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
                        ],
                      );
                    },
                  ),
                  CommonWidgets.sliverBottomSpace,
                ],
              ),
            );
          },
        ),
      ),
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

    return SliverPinnedToBoxAdapter(
      child: Container(
        padding: edgeH16V8,
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
                style: textStyle20B,
              ),
            ),
            Tooltip(
              message: full,
              child: Text(
                simple,
                style: TextStyle(
                  color: theme.textTheme.subtitle1?.color,
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

  Widget _buildOVASection() {
    return Selector<IndexModel, List<RecordItem>>(
      selector: (_, model) => model.ovas,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, ovas, child) {
        if (ovas.isSafeNotEmpty) return child!;
        return sliverToBoxAdapter;
      },
      child: SliverToBoxAdapter(
        child: Padding(
          padding: edgeH16T8,
          child: Text(
            "剧场版/OVA",
            style: textStyle20B,
          ),
        ),
      ),
    );
  }

  Widget _buildCarousels(final ThemeData theme) {
    return Selector<IndexModel, List<Carousel>>(
      selector: (_, model) => model.carousels,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, carousels, __) {
        if (carousels.isNotEmpty)
          return SliverToBoxAdapter(
            child: CarouselSlider.builder(
              itemBuilder: (context, index, _) {
                final carousel = carousels[index];
                final String currFlag =
                    "carousel:${carousel.id}:${carousel.cover}";
                return _buildCarouselsItem(
                  context,
                  theme,
                  currFlag,
                  carousel,
                );
              },
              itemCount: carousels.length,
              options: CarouselOptions(
                height: 180,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
            ),
          );
        return sliverToBoxAdapter;
      },
    );
  }

  Widget _buildCarouselsItem(
    final BuildContext context,
    final ThemeData theme,
    final String currFlag,
    final Carousel carousel,
  ) {
    return Hero(
      tag: currFlag,
      child: TapScaleContainer(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.bangumi.name,
            arguments: Routes.bangumi.d(
              heroTag: currFlag,
              bangumiId: carousel.id,
              cover: carousel.cover,
            ),
          );
        },
        margin: edgeT16B12,
        decoration: BoxDecoration(
          borderRadius: borderRadius16,
          color: theme.backgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.08),
            )
          ],
          image: DecorationImage(
            fit: BoxFit.cover,
            image: ExtendedNetworkImageProvider(carousel.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(final BuildContext context, final ThemeData theme) {
    return SliverPinnedToBoxAdapter(
      child: Selector<IndexModel, bool>(
        selector: (_, model) => model.hasScrolled,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, hasScrolled, child) {
          return AnimatedContainer(
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Selector<IndexModel, User?>(
                        selector: (_, model) => model.user,
                        shouldRebuild: (pre, next) => pre != next,
                        builder: (_, user, __) {
                          final withoutName =
                              user == null || user.name.isNullOrBlank;
                          return Text(
                            withoutName ? "Mikan Project" : "Hi, ${user!.name}",
                            style: textStyle14B,
                          );
                        },
                      ),
                      _buildSeasonSelector(context, theme, hasScrolled)
                    ],
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    _showSearchPanel(context);
                  },
                  child: Icon(FluentIcons.search_24_regular),
                  minWidth: 0,
                  padding: edge10,
                  shape: CircleBorder(),
                ),
                MaterialButton(
                  onPressed: () {
                    _showSettingsPanel(context);
                  },
                  child: _buildAvatar(),
                  minWidth: 0,
                  padding: EdgeInsets.all(10.0),
                  shape: CircleBorder(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeasonSelector(
    final BuildContext context,
    final ThemeData theme,
    final bool hasScrolled,
  ) {
    return Row(
      children: [
        Selector<IndexModel, Season?>(
          selector: (_, model) => model.selectedSeason,
          shouldRebuild: (pre, next) => pre != next,
          builder: (_, season, __) {
            return season == null
                ? sizedBox
                : Text(
                    season.title,
                    style: TextStyle(
                      fontSize: 24.0,
                      height: 1.25,
                      fontWeight: FontWeight.bold,
                    ),
                  );
          },
        ),
        MaterialButton(
          onPressed: () {
            _showYearSeasonBottomSheet(context);
          },
          child: Icon(
            FluentIcons.chevron_down_24_regular,
            size: 16.0,
          ),
          minWidth: 0,
          color: hasScrolled
              ? theme.scaffoldBackgroundColor
              : theme.backgroundColor,
          padding: EdgeInsets.all(5.0),
          shape: CircleBorder(),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Selector<IndexModel, User?>(
      selector: (_, model) => model.user,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, user, __) {
        return user?.hasLogin == true
            ? ClipOval(
                child: ExtendedImage(
                  image: ExtendedNetworkImageProvider(user!.avatar ?? ""),
                  width: 36.0,
                  height: 36.0,
                  loadStateChanged: (state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                      case LoadState.failed:
                        return ExtendedImage.asset(
                          "assets/mikan.png",
                          width: 36.0,
                          height: 36.0,
                        );
                      case LoadState.completed:
                        return null;
                    }
                  },
                ),
              )
            : ExtendedImage.asset(
                "assets/mikan.png",
                width: 36.0,
                height: 36.0,
              );
      },
    );
  }

  Future _showYearSeasonBottomSheet(final BuildContext context) {
    return showCupertinoModalBottomSheet(
      context: context,
      topRadius: Radius.circular(16.0),
      builder: (_) {
        return SelectSeasonFragment();
      },
    );
  }

  Widget _buildOVAList(final ThemeData theme) {
    return Selector<IndexModel, List<RecordItem>>(
      selector: (_, model) => model.ovas,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, records, __) {
        if (records.isNullOrEmpty) return sliverToBoxAdapter;
        return SliverToBoxAdapter(
          child: Container(
            height: 156.0,
            padding: EdgeInsets.only(bottom: 12.0, top: 12.0),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: records.length,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16.0),
              itemBuilder: (context, index) {
                final RecordItem record = records[index];
                return OVARecordItem(
                  index: index,
                  record: record,
                  theme: theme,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.recordDetail.name,
                      arguments: Routes.recordDetail.d(url: record.url),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  _showSearchPanel(final BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      bounce: true,
      enableDrag: false,
      topRadius: Radius.circular(16.0),
      builder: (_) {
        return SearchFragment();
      },
    );
  }

  void _showSettingsPanel(final BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      topRadius: Radius.circular(16.0),
      builder: (_) {
        return SettingsFragment();
      },
    );
  }
}
