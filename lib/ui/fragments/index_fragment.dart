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
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/ui/components/ova_record_item.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:mikan_flutter/ui/fragments/search_fragment.dart';
import 'package:mikan_flutter/ui/fragments/season_modal_fragment.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@immutable
class IndexFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).accentColor;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentTextColor =
        accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
    final TextStyle fileTagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: accentTextColor,
    );
    final TextStyle titleTagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color:
          primaryColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    final Color backgroundColor = Theme.of(context).backgroundColor;
    final Color scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;
    final Color subtitleColor = Theme.of(context).textTheme.subtitle1.color;
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
              context.read<IndexModel>().hasScrolled = offset > 0.0;
            }
          }
          return true;
        },
        child: Selector<IndexModel, List<BangumiRow>>(
          selector: (_, model) => model.bangumiRows,
          shouldRebuild: (pre, next) => pre.ne(next),
          builder: (_, bangumiRows, __) {
            return SmartRefresher(
              controller: indexModel.refreshController,
              enablePullUp: false,
              enablePullDown: true,
              header: WaterDropMaterialHeader(
                backgroundColor: accentColor,
                color: accentTextColor,
                distance: Sz.statusBarHeight + 10.0,
              ),
              onRefresh: indexModel.refresh,
              child: CustomScrollView(
                slivers: [
                  _buildHeader(
                    context,
                    backgroundColor,
                    scaffoldBackgroundColor,
                  ),
                  _buildCarousels(),
                  _buildOVASection(),
                  _buildOVAList(
                    accentColor,
                    primaryColor,
                    backgroundColor,
                    fileTagStyle,
                    titleTagStyle,
                  ),
                  ...List.generate(bangumiRows.length, (index) {
                    final BangumiRow bangumiRow = bangumiRows[index];
                    return [
                      _buildWeekSection(
                        scaffoldBackgroundColor,
                        subtitleColor,
                        bangumiRow,
                      ),
                      BangumiSliverGridFragment(
                        bangumis: bangumiRow.bangumis,
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
  }

  Widget _buildWeekSection(
    final Color scaffoldBackgroundColor,
    final Color subtitleColor,
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
          bottom: 8.0,
        ),
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor,
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
                  color: subtitleColor,
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
        if (ovas.isSafeNotEmpty) return child;
        return SliverToBoxAdapter();
      },
      child: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 8.0,
          ),
          child: Text(
            "OVA/剧场版 (beta)",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarousels() {
    return Selector<IndexModel, List<Carousel>>(
      selector: (_, model) => model.carousels,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, carousels, __) {
        if (carousels.isNotEmpty)
          return SliverToBoxAdapter(
            child: CarouselSlider.builder(
              itemBuilder: (context, index) {
                final carousel = carousels[index];
                final String currFlag =
                    "carousel:${carousel.id}:${carousel.cover}";
                return Selector<IndexModel, String>(
                  selector: (_, model) => model.tapBangumiCarouselItemFlag,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (context, tapScaleFlag, child) {
                    final Matrix4 transform = tapScaleFlag == currFlag
                        ? Matrix4.diagonal3Values(0.8, 0.8, 1)
                        : Matrix4.identity();
                    return Hero(
                      tag: currFlag,
                      child: AnimatedTapContainer(
                        transform: transform,
                        onTapStart: () => context
                            .read<IndexModel>()
                            .tapBangumiCarouselItemFlag = currFlag,
                        onTapEnd: () => context
                            .read<IndexModel>()
                            .tapBangumiCarouselItemFlag = null,
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
                        margin: EdgeInsets.only(top: 16.0, bottom: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          color: Theme.of(context).backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black.withOpacity(0.08),
                            )
                          ],
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: ExtendedNetworkImageProvider(
                              carousel.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
        return SliverToBoxAdapter();
      },
    );
  }

  Widget _buildHeader(
    final BuildContext context,
    final Color backgroundColor,
    final Color scaffoldBackgroundColor,
  ) {
    return SliverPinnedToBoxAdapter(
      child: Selector<IndexModel, bool>(
        selector: (_, model) => model.hasScrolled,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, hasScrolled, child) {
          return AnimatedContainer(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0 + Sz.statusBarHeight,
              bottom: 4.0,
            ),
            decoration: BoxDecoration(
              color: hasScrolled ? backgroundColor : scaffoldBackgroundColor,
              borderRadius: hasScrolled
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    )
                  : null,
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
            ),
            duration: Duration(milliseconds: 240),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Selector<IndexModel, User>(
                        selector: (_, model) => model.user,
                        shouldRebuild: (pre, next) => pre != next,
                        builder: (_, user, __) {
                          final withoutName =
                              user == null || user.name.isNullOrBlank;
                          return Text(
                            withoutName
                                ? "Welcome to Mikan"
                                : "Hi, ${user.name}",
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.25,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Row(
                        children: [
                          Selector<IndexModel, Season>(
                            selector: (_, model) => model.selectedSeason,
                            shouldRebuild: (pre, next) => pre != next,
                            builder: (_, season, __) {
                              return season == null
                                  ? Container()
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
                                ? scaffoldBackgroundColor
                                : backgroundColor,
                            padding: EdgeInsets.all(5.0),
                            shape: CircleBorder(),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    _showSearchPanel(context);
                  },
                  child: Icon(FluentIcons.search_24_regular),
                  minWidth: 0,
                  padding: EdgeInsets.all(10.0),
                  shape: CircleBorder(),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.login);
                  },
                  child: Selector<IndexModel, User>(
                    selector: (_, model) => model.user,
                    shouldRebuild: (pre, next) => pre != next,
                    builder: (_, user, __) {
                      return user?.avatar?.isNotBlank == true
                          ? ClipOval(
                              child: ExtendedImage.network(
                                user?.avatar,
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
                                  return null;
                                },
                              ),
                            )
                          : ExtendedImage.asset(
                              "assets/mikan.png",
                              width: 36.0,
                              height: 36.0,
                            );
                    },
                  ),
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

  Future _showYearSeasonBottomSheet(final BuildContext context) {
    return showCupertinoModalBottomSheet(
      context: context,
      topRadius: Radius.circular(16.0),
      builder: (context) {
        return SeasonModalFragment();
      },
    );
  }

  Widget _buildOVAList(
    final Color accentColor,
    final Color primaryColor,
    final Color backgroundColor,
    final TextStyle fileTagStyle,
    final TextStyle titleTagStyle,
  ) {
    return Selector<IndexModel, List<RecordItem>>(
      selector: (_, model) => model.ovas,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, records, __) {
        if (records.isNullOrEmpty) return SliverToBoxAdapter();
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 160.0,
            child: ListView.builder(
              itemCount: records.length,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16.0),
              itemBuilder: (context, index) {
                final RecordItem record = records[index];
                final String currFlag = "ova:$index";
                return Selector<IndexModel, String>(
                  selector: (_, model) => model.tapBangumiOVAItemFlag,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (_, tapScaleFlag, __) {
                    final Matrix4 transform = tapScaleFlag == currFlag
                        ? Matrix4.diagonal3Values(0.9, 0.9, 1)
                        : Matrix4.identity();
                    return OVARecordItem(
                      index: index,
                      record: record,
                      accentColor: accentColor,
                      primaryColor: primaryColor,
                      backgroundColor: backgroundColor,
                      fileTagStyle: fileTagStyle,
                      titleTagStyle: titleTagStyle,
                      transform: transform,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.recordDetail.name,
                          arguments: Routes.recordDetail.d(url: record.url),
                        );
                      },
                      onTapStart: () {
                        context.read<IndexModel>().tapBangumiOVAItemFlag =
                            currFlag;
                      },
                      onTapEnd: () {
                        context.read<IndexModel>().tapBangumiOVAItemFlag = null;
                      },
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
      builder: (context) {
        return SearchFragment();
      },
    );
  }
}
