import 'package:extended_sliver/extended_sliver.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/model/carousel.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/user.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/providers/op_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/components/ova_record_item.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:mikan_flutter/ui/fragments/search_fragment.dart';
import 'package:mikan_flutter/ui/fragments/select_season_fragment.dart';
import 'package:mikan_flutter/ui/fragments/settings_fragment.dart';
import 'package:mikan_flutter/widget/icon_button.dart';
import 'package:mikan_flutter/widget/sliver_pinned_header.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class IndexFragment extends StatefulWidget {
  const IndexFragment({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IndexFragmentState();
}

class _IndexFragmentState extends State<IndexFragment> {
  final InfiniteScrollController _infiniteScrollController =
      InfiniteScrollController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final indexModel = Provider.of<IndexModel>(context, listen: false);
    return Scaffold(
      body: Selector<IndexModel, List<BangumiRow>>(
        selector: (_, model) => model.bangumiRows,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, bangumiRows, __) {
          if (bangumiRows.isNullOrEmpty && indexModel.seasonLoading) {
            return centerLoading;
          }
          return SmartRefresher(
            controller: indexModel.refreshController,
            enablePullUp: false,
            enablePullDown: true,
            header: WaterDropMaterialHeader(
              backgroundColor: theme.secondary,
              color: theme.secondary.isDark ? Colors.white : Colors.black,
              distance: Screen.statusBarHeight + 42.0,
            ),
            onRefresh: indexModel.refresh,
            child: CustomScrollView(
              slivers: [
                _buildHeader(),
                _buildCarousels(theme),
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
                  },
                ),
                _buildOVA(theme),
                sliverSizedBoxH80WithNavBarHeight,
              ],
            ),
          );
        },
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
      child: Transform.translate(
        offset: offsetY_1,
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
                    fontSize: 14.0,
                    height: 1.25,
                  ),
                ),
              ),
            ],
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
        if (carousels.isNotEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              margin: edgeV8,
              height: 148.0,
              child: InfiniteCarousel.builder(
                itemBuilder: (context, index, realIndex) {
                  final carousel = carousels[index];
                  final String currFlag =
                      "carousel:$realIndex:${carousel.id}:${carousel.cover}";
                  final currentOffset = 328 * realIndex;
                  return AnimatedBuilder(
                    animation: _infiniteScrollController,
                    builder: (_, __) {
                      final diff =
                          (_infiniteScrollController.offset - currentOffset);
                      final ver = (diff / 36).abs();
                      double hor = (diff / 72).abs();
                      if (hor < 8.0) {
                        hor = 8.0;
                      } else if (hor > 12.0) {
                        hor = 12.0;
                      }
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
                          margin: EdgeInsets.symmetric(
                            horizontal: hor,
                            vertical: ver > 8.0 ? 8.0 : ver,
                          ),
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
                              image: CacheImageProvider(carousel.cover),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                controller: _infiniteScrollController,
                itemExtent: 328.0,
                itemCount: carousels.length,
                center: true,
                velocityFactor: 0.8,
              ),
            ),
          );
        }
        return emptySliverToBoxAdapter;
      },
    );
  }

  Widget _buildHeader() {
    return const _PinedHeader();
  }

  Widget _buildOVA(final ThemeData theme) {
    return Selector<IndexModel, List<RecordItem>>(
      selector: (_, model) => model.ovas,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, records, __) {
        if (records.isNullOrEmpty) return emptySliverToBoxAdapter;
        final simple = "🚀 ${records.length}条";
        final full = "更新${records.length}条记录";
        return MultiSliver(
          pushPinnedChildren: true,
          children: [
            SliverPinnedToBoxAdapter(
                child: Container(
              padding: edgeH16V8,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      "最近更新 • 剧场版/OVA",
                      style: textStyle20B,
                    ),
                  ),
                  Tooltip(
                    message: full,
                    child: Text(
                      simple,
                      style: TextStyle(
                        color: theme.textTheme.subtitle1?.color,
                        fontSize: 14.0,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            SliverPadding(
              padding: edgeHB16T4,
              sliver: SliverWaterfallFlow(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
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
                  childCount: records.length,
                ),
                gridDelegate:
                    const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  minCrossAxisExtent: 360,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

void showSearchPanel(final BuildContext context) {
  showCupertinoModalBottomSheet(
    context: context,
    expand: true,
    bounce: true,
    enableDrag: false,
    topRadius: radius16,
    builder: (_) {
      return const SearchFragment();
    },
  );
}

void showSettingsPanel(final BuildContext context) {
  showCupertinoModalBottomSheet(
    context: context,
    topRadius: radius16,
    builder: (_) {
      return const SettingsFragment();
    },
  );
}

void showYearSeasonBottomSheet(final BuildContext context) {
  showCupertinoModalBottomSheet(
    context: context,
    topRadius: radius16,
    builder: (_) {
      return const SelectSeasonFragment();
    },
  );
}

class _PinedHeader extends StatelessWidget {
  const _PinedHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final it = ColorTween(
      begin: theme.backgroundColor,
      end: theme.scaffoldBackgroundColor,
    );
    return StackSliverPinnedHeader(
      minExtent: Screen.statusBarHeight + 76,
      childrenBuilder: (context, ratio) {
        final ic = it.transform(ratio);
        return [
          Positioned(
            top: 52 * (1 - ratio) + 16 + Screen.statusBarHeight,
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Selector<IndexModel, User?>(
                  selector: (_, model) => model.user,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (_, user, __) {
                    final withoutName = user == null || user.name.isNullOrBlank;
                    return Text(
                      withoutName ? "Mikan Project" : "Hi, ${user.name}",
                      style: textStyle14B500,
                    );
                  },
                ),
                Row(
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
                                  fontSize: 30.0 - (ratio * 6.0),
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                ),
                              );
                      },
                    ),
                    sizedBoxW8,
                    CustomIconButton(
                      onPressed: () {
                        showYearSeasonBottomSheet(context);
                      },
                      size: 28.0,
                      backgroundColor: ic,
                      iconData: FluentIcons.chevron_down_24_regular,
                      iconSize: 14.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 12.0 + Screen.statusBarHeight,
            child: Row(
              children: [
                MaterialButton(
                  onPressed: () {
                    showSearchPanel(context);
                  },
                  minWidth: 48.0,
                  padding: edge8,
                  shape: circleShape,
                  child: const Icon(FluentIcons.search_24_regular),
                ),
                MaterialButton(
                  onPressed: () {
                    showSettingsPanel(context);
                  },
                  minWidth: 48.0,
                  padding: edge8,
                  shape: circleShape,
                  child: _buildAvatar(),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }

  Widget _buildAvatar() {
    return Selector<IndexModel, User?>(
      selector: (_, model) => model.user,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, user, __) {
        return user?.hasLogin == true
            ? ClipOval(
                child: Image(
                  image: CacheImageProvider(user!.avatar ?? ""),
                  width: 36.0,
                  height: 36.0,
                  loadingBuilder: (_, child, event) {
                    return event == null
                        ? child
                        : Image.asset(
                            "assets/mikan.png",
                            width: 36.0,
                            height: 36.0,
                          );
                  },
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      "assets/mikan.png",
                      width: 36.0,
                      height: 36.0,
                    );
                  },
                ),
              )
            : Image.asset(
                "assets/mikan.png",
                width: 36.0,
                height: 36.0,
              );
      },
    );
  }
}
