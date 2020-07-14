import 'dart:math' as Math;

import 'package:ant_icons/ant_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/ext/face.dart';
import 'package:mikan_flutter/ext/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/ui/fragments/week_tab_fragment.dart';
import 'package:provider/provider.dart';

@immutable
class IndexFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Widget seasonSectionControlUI = buildWeekSectionControlUI(context);
    final Widget loader = buildLoader();
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: NestedScrollViewRefreshIndicator(
          displacement: 48.0,
          onRefresh: Provider.of<IndexModel>(context, listen: false).loadIndex,
          child: NestedScrollView(
            body: Selector<IndexModel, bool>(
              selector: (_, model) => model.seasonLoading,
              shouldRebuild: (pre, next) => pre != next,
              builder: (_, loading, ___) {
                final List<BangumiRow> bangumiRows =
                    context.read<IndexModel>().bangumiRows;
                return WeekTabFragment(
                  bangumiRows: bangumiRows,
                  header: seasonSectionControlUI,
                  loading: loading,
                  loader: loader,
                  onTabChange: (index) {
                    context.read<IndexModel>().selectedTabIndex = index;
                  },
                );
              },
            ),
            headerSliverBuilder: (context, __) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
                      buildSearchUI(context),
                      buildCarouselsUI(),
                    ],
                  ),
                )
              ];
            },
            innerScrollPositionKeyBuilder: () {
              return Key(context.read<IndexModel>().selectTabName);
            },
          ),
        ),
      ),
    );
  }

  Widget buildLoader() {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SpinKitPumpingHeart(
              duration: Duration(milliseconds: 960),
              itemBuilder: (_, __) => Image.asset(
                "assets/mikan.png",
                width: 108.0,
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              randomFace(),
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              "请不要走开，精彩马上就来",
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCarouselsUI() {
    return Selector<IndexModel, List<Carousel>>(
      selector: (_, model) => model.carousels,
      shouldRebuild: (pre, next) => pre.length != next.length,
      builder: (_, carousels, __) {
        if (carousels.isNotEmpty)
          return SizedBox(
            width: double.infinity,
            height: (Sz.screenWidth - 32) / (375 / 196) + 32,
            child: Swiper(
              autoplay: true,
              duration: 480,
              autoplayDelay: 4800,
              itemWidth: Sz.screenWidth - 32,
              layout: SwiperLayout.STACK,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(top: 12.0, bottom: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black.withAlpha(24),
                      )
                    ],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(
                        carousels[index].cover,
                      ),
                    ),
                  ),
                );
              },
              itemCount: carousels.length,
            ),
          );
        return Container();
      },
    );
  }

  Widget buildWeekSectionControlUI(final BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 12.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Welcome to Mikan",
                ),
                Selector<IndexModel, Season>(
                  selector: (_, model) => model.selectedSeason,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (_, season, __) {
                    return season == null
                        ? Container()
                        : Text(
                            season.title,
                            style: TextStyle(
                              fontSize: 28,
                            ),
                          );
                  },
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(AntIcons.double_left),
                  onPressed: () {
                    context.read<IndexModel>().prevSeason();
                  },
                ),
                IconButton(
                  icon: Icon(AntIcons.calendar_outline),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Transform.rotate(
                    angle: Math.pi,
                    child: Icon(AntIcons.double_left),
                  ),
                  onPressed: () {
                    context.read<IndexModel>().nextSeason();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildSearchUI(final BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0, bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: Icon(AntIcons.search_outline),
                labelText: 'Search for anime',
                border: InputBorder.none,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
              onEditingComplete: () {},
            ),
          ),
          Ink(
            decoration: ShapeDecoration(
              shape: CircleBorder(),
            ),
            child: IconButton(
              iconSize: 36.0,
              icon: Selector<IndexModel, User>(
                selector: (_, model) => model.user,
                shouldRebuild: (pre, next) => pre != next,
                builder: (_, user, __) {
                  return user?.avatar?.isNotBlank == true
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: user?.avatar,
                            placeholder: (_, __) =>
                                Image.asset("assets/mikan.png"),
                            errorWidget: (_, __, ___) =>
                                Image.asset("assets/mikan.png"),
                          ),
                        )
                      : Image.asset("assets/mikan.png");
                },
              ),
              onPressed: () {
                Navigator.pushNamed(context, Routes.mikanLogin);
              },
            ),
          )
        ],
      ),
    );
  }
}
