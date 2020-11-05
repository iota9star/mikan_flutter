import 'dart:math' as Math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_grid_fragment.dart';
import 'package:mikan_flutter/ui/fragments/search_fragment.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

@immutable
class IndexFragment extends StatelessWidget {
  final ValueNotifier<double> _scrollNotifier = ValueNotifier<double>(0.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener(
        onNotification: (notification) {
          if (notification is OverscrollIndicatorNotification) {
            notification.disallowGlow();
          } else if (notification is ScrollUpdateNotification) {
            if (notification.depth == 0) {
              final double offset = notification.metrics.pixels;
              context.read<IndexModel>().hasScrolled = offset > 0;
              _scrollNotifier.value = offset;
            }
          }
          return false;
        },
        child: Selector<IndexModel, List<BangumiRow>>(
          selector: (_, model) => model.bangumiRows,
          shouldRebuild: (pre, next) => pre != next,
          builder: (_, bangumiRows, __) {
            return CustomScrollView(
              slivers: [
                SliverPinnedToBoxAdapter(
                  child: _buildHeader(context),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
                      _buildCarousels(),
                      _buildRssList(),
                    ],
                  ),
                ),
                ...List.generate(bangumiRows.length, (index) {
                  final BangumiRow bangumiRow = bangumiRows[index];
                  if (bangumiRow == null) return Container();
                  final simple = [
                    if (bangumiRow.updatedNum > 0)
                      "🚀 ${bangumiRow.updatedNum}部",
                    if (bangumiRow.subscribedUpdatedNum > 0)
                      "💖 ${bangumiRow.subscribedUpdatedNum}部",
                    if (bangumiRow.subscribedNum > 0)
                      "❤ ${bangumiRow.subscribedNum}部",
                    "🎬 ${bangumiRow.num}部"
                  ].join("，");
                  final full = [
                    if (bangumiRow.updatedNum > 0)
                      "更新${bangumiRow.updatedNum}部",
                    if (bangumiRow.subscribedUpdatedNum > 0)
                      "订阅更新${bangumiRow.subscribedUpdatedNum}部",
                    if (bangumiRow.subscribedNum > 0)
                      "订阅${bangumiRow.subscribedNum}部",
                    "共${bangumiRow.num}部"
                  ].join("，");
                  return [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.only(
                          top: 16.0,
                          left: 16.0,
                          right: 16.0,
                          bottom: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          // boxShadow: [
                          //   BoxShadow(
                          //     offset: Offset(0, 4.0),
                          //     blurRadius: 12.0,
                          //     spreadRadius: -12.0,
                          //     color: Colors.black26,
                          //   )
                          // ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                bangumiRow.name,
                                style: TextStyle(
                                  fontSize: 20,
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color,
                                  fontSize: 12.0,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    BangumiGridFragment(
                      bangumis: bangumiRow.bangumis,
                      scrollNotifier: _scrollNotifier,
                    ),
                  ];
                }).expand((element) => element),
                // Selector<IndexModel, bool>(
                //   selector: (_, model) => model.seasonLoading,
                //   shouldRebuild: (pre, next) => pre != next,
                //   builder: (_, loading, ___) {
                //     final List<BangumiRow> bangumiRows =
                //         context.read<IndexModel>().bangumiRows;
                //     return BangumiGridFragment(
                //       bangumiRows: bangumiRows,
                //       scrollNotifier: _scrollNotifier,
                //     );
                //   },
                // ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRssList() {
    return Selector<IndexModel, Map<String, List<RecordItem>>>(
      selector: (_, model) => model.rss,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, rss, __) {
        if (rss.isNotEmpty)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                ),
                child: Text(
                  "我的订阅 ❤ 昨日至今",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              SizedBox(
                height: 64.0 + 24.0,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return _buildMoreRssItemBtn(context, rss);
                    }
                    final entry = rss.entries.elementAt(index - 1);
                    return _buildRssListItemCover(entry);
                  },
                  itemCount: rss.length + 1,
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                ),
              ),
            ],
          );
        return Container();
      },
    );
  }

  Selector<IndexModel, String> _buildMoreRssItemBtn(
      BuildContext context, Map<String, List<RecordItem>> rss) {
    return Selector<IndexModel, String>(
      selector: (_, model) => model.tapBangumiRssItemFlag,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, tapScaleFlag, child) {
        final String currFlag = "rss:more-rss";
        final Matrix4 transform = tapScaleFlag == currFlag
            ? Matrix4.diagonal3Values(0.9, 0.9, 1)
            : Matrix4.identity();
        return AnimatedTapContainer(
          transform: transform,
          onTapStart: () =>
              context.read<IndexModel>().tapBangumiRssItemFlag = currFlag,
          onTapEnd: () =>
              context.read<IndexModel>().tapBangumiRssItemFlag = null,
          width: 64.0,
          margin: EdgeInsets.symmetric(
            horizontal: 6.0,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(
                rss.entries
                    .elementAt(0)
                    .value[0].cover,
              ),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 8.0,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Center(
            child: Text(
              "更多\n订阅",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme
                    .of(context)
                    .accentColor,
                height: 1.25,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRssListItemCover(
      final MapEntry<String, List<RecordItem>> entry,) {
    final List<RecordItem> records = entry.value;
    final int recordsLength = records.length;
    final String bangumiCover = records[0].cover;
    final String bangumiId = entry.key;
    final String badge = recordsLength > 99 ? "99+" : "+$recordsLength";
    final String currFlag = "rss:$bangumiId:$bangumiCover";
    return Selector<IndexModel, String>(
      shouldRebuild: (pre, next) => pre != next,
      selector: (_, model) => model.tapBangumiRssItemFlag,
      builder: (context, tapScaleFlag, child) {
        final Matrix4 transform = tapScaleFlag == currFlag
            ? Matrix4.diagonal3Values(0.9, 0.9, 1)
            : Matrix4.identity();
        return AnimatedTapContainer(
          transform: transform,
          onTapStart: () =>
          context
              .read<IndexModel>()
              .tapBangumiRssItemFlag = currFlag,
          onTapEnd: () =>
          context
              .read<IndexModel>()
              .tapBangumiRssItemFlag = null,
          width: 64.0,
          margin: EdgeInsets.symmetric(
            horizontal: 6.0,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 8.0,
                color: Colors.black.withOpacity(0.08),
              ),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.bangumiDetails,
              arguments: {
                "heroTag": currFlag,
                "bangumiId": bangumiId,
                "cover": bangumiCover,
              },
            );
          },
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        child: Stack(
          fit: StackFit.loose,
          overflow: Overflow.clip,
          children: [
            Positioned.fill(
              child: Hero(
                tag: currFlag,
                child: CachedNetworkImage(
                  imageUrl: bangumiCover,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: SpinKitPumpingHeart(
                            duration: Duration(milliseconds: 960),
                            itemBuilder: (_, __) =>
                                Image.asset(
                                  "assets/mikan.png",
                                ),
                          ),
                        ),
                      ),
                  errorWidget: (_, __, ___) =>
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Image.asset(
                            "assets/mikan.png",
                          ),
                        ),
                      ),
                ),
              ),
            ),
            Positioned(
              right: -20.0,
              top: -8,
              child: Transform.rotate(
                angle: Math.pi / 4.0,
                child: Container(
                  width: 48.0,
                  padding: EdgeInsets.only(top: 12.0),
                  color: Colors.redAccent,
                  child: Text(
                    badge,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousels() {
    return Selector<IndexModel, List<Carousel>>(
      selector: (_, model) => model.carousels,
      shouldRebuild: (pre, next) => pre.length != next.length,
      builder: (context, carousels, __) {
        if (carousels.isNotEmpty)
          return CarouselSlider.builder(
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
                      onTapStart: () =>
                      context
                          .read<IndexModel>()
                          .tapBangumiCarouselItemFlag = currFlag,
                      onTapEnd: () =>
                      context
                          .read<IndexModel>()
                          .tapBangumiCarouselItemFlag = null,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.bangumiDetails,
                          arguments: {
                            "heroTag": currFlag,
                            "bangumiId": carousel.id,
                            "cover": carousel.cover,
                          },
                        );
                      },
                      margin: EdgeInsets.only(top: 16.0, bottom: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        color: Theme
                            .of(context)
                            .backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.08),
                          )
                        ],
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
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
          );
        return Container();
      },
    );
  }

  Widget _buildHeader(final BuildContext context) {
    return Selector<IndexModel, bool>(
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
              color: Theme
                  .of(context)
                  .scaffoldBackgroundColor,
              boxShadow: hasScrolled
                  ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.024),
                  offset: Offset(0, 1),
                  blurRadius: 3.0,
                  spreadRadius: 3.0,
                ),
              ]
                  : null),
          duration: Duration(milliseconds: 240),
          child: child,
        );
      },
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Selector<IndexModel, User>(
                  builder: (_, user, __) {
                    final withoutName = user == null || user.name.isNullOrBlank;
                    return Text(
                      withoutName ? "Welcome to Mikan" : "Hi, ${user.name}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                  selector: (_, model) => model.user,
                  shouldRebuild: (pre, next) => pre != next,
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
                        Icons.keyboard_arrow_down,
                        size: 16.0,
                      ),
                      minWidth: 0,
                      color: Theme
                          .of(context)
                          .backgroundColor,
                      padding: EdgeInsets.all(6.0),
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
                  child: CachedNetworkImage(
                    width: 36.0,
                    height: 36.0,
                    imageUrl: user?.avatar,
                    placeholder: (_, __) =>
                        Image.asset(
                          "assets/mikan.png",
                          width: 36.0,
                          height: 36.0,
                        ),
                    errorWidget: (_, __, ___) =>
                        Image.asset(
                          "assets/mikan.png",
                          width: 36.0,
                          height: 36.0,
                        ),
                  ),
                )
                    : Image.asset(
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
  }

  Future _showYearSeasonBottomSheet(final BuildContext context) {
    return showCupertinoModalBottomSheet(
      context: context,
      topRadius: Radius.circular(24.0),
      builder: (context, controller) {
        return Material(
          color: Theme
              .of(context)
              .backgroundColor,
          child: SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 24.0,
                bottom: 16.0 + Sz.navBarHeight,
              ),
              child: Selector<IndexModel, List<YearSeason>>(
                selector: (_, model) => model.years,
                shouldRebuild: (pre, next) => pre != next,
                builder: (_, years, __) {
                  if (years.isNullOrEmpty) return Container();
                  final widgets = List.generate(
                    years.length,
                        (index) {
                      final year = years[index];
                      return Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            year.year,
                            style: TextStyle(
                              fontSize: 20.0,
                              height: 1.25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 12.0),
                          ...List.generate(
                            4,
                                (index) {
                              if (year.seasons.length > index) {
                                return _buildSeasonItem(year.seasons[index]);
                              } else {
                                return Flexible(
                                  child: FractionallySizedBox(widthFactor: 1),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "番组列表",
                        style: TextStyle(
                          fontSize: 24.0,
                          height: 1.25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.0),
                      ...widgets
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Flexible _buildSeasonItem(final Season season) {
    return Flexible(
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Selector<IndexModel, Season>(
            selector: (_, model) => model.selectedSeason,
            shouldRebuild: (pre, next) => pre != next,
            builder: (context, selectedSeason, _) {
              final Color color = season.title == selectedSeason.title
                  ? Theme
                  .of(context)
                  .primaryColor
                  : Theme
                  .of(context)
                  .accentColor;
              return Tooltip(
                message: season.title,
                child: MaterialButton(
                  minWidth: 0,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    season.season,
                    style: TextStyle(
                      fontSize: 18.0,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  color: color.withOpacity(0.12),
                  elevation: 0,
                  onPressed: () {
                    context.read<IndexModel>().loadSeason(season);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  _showSearchPanel(final BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      bounce: true,
      enableDrag: false,
      topRadius: Radius.circular(24.0),
      builder: (context, scrollController) {
        return SearchFragment(
          scrollController: scrollController,
        );
      },
    );
  }
// Future _showYearSeasonBottomSheet(BuildContext context) {
//   return showCupertinoModalBottomSheet(
//     context: context,
//     expand: false,
//     builder: (context, controller) {
//       return Material(
//         color: Theme.of(context).backgroundColor,
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 16.0,
//             right: 16.0,
//             top: 16.0,
//             bottom: 16.0 + Sz.navBarHeight,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "番组列表",
//                 style: TextStyle(
//                   fontSize: 24.0,
//                   height: 1.25,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 12.0),
//               Expanded(
//                 child: Selector<IndexModel, List<YearSeason>>(
//                   selector: (_, model) => model.years,
//                   shouldRebuild: (pre, next) => pre != next,
//                   builder: (_, years, __) {
//                     return ListView.builder(
//                       itemCount: years.length,
//                       controller: controller,
//                       itemBuilder: (context, index) {
//                         final year = years[index];
//                         return Row(
//                           mainAxisSize: MainAxisSize.max,
//                           children: [
//                             Text(
//                               year.year,
//                               style: TextStyle(
//                                 fontSize: 20.0,
//                                 height: 1.25,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             SizedBox(width: 16.0),
//                             ...List.generate(
//                               4,
//                               (index) {
//                                 if (year.seasons.length > index) {
//                                   final String season =
//                                       year.seasons[index].season;
//                                   return Flexible(
//                                     child: FractionallySizedBox(
//                                       widthFactor: 1,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: MaterialButton(
//                                           minWidth: 0,
//                                           materialTapTargetSize:
//                                               MaterialTapTargetSize
//                                                   .shrinkWrap,
//                                           padding: EdgeInsets.all(0.0),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.all(
//                                               Radius.circular(10.0),
//                                             ),
//                                           ),
//                                           child: Text(
//                                             season,
//                                             style: TextStyle(
//                                               fontSize: 18.0,
//                                               height: 1.25,
//                                               fontWeight: FontWeight.w500,
//                                               color: Theme.of(context)
//                                                   .accentColor,
//                                             ),
//                                           ),
//                                           color: Theme.of(context)
//                                               .accentColor
//                                               .withOpacity(0.3),
//                                           elevation: 0,
//                                           onPressed: () {},
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 } else {
//                                   return Flexible(
//                                     child:
//                                         FractionallySizedBox(widthFactor: 1),
//                                   );
//                                 }
//                               },
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               )
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
}
