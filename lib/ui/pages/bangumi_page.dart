import 'dart:math' as math;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi_details.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/bangumi_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/fragments/subgroup_bangumis_fragment.dart';
import 'package:mikan_flutter/widget/icon_button.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@FFRoute(
  name: "bangumi",
  routeName: "/bangumi",
)
@immutable
class BangumiPage extends StatelessWidget {
  final String heroTag;
  final String bangumiId;
  final String cover;

  BangumiPage({
    Key? key,
    required this.bangumiId,
    required this.cover,
    required this.heroTag,
  }) : super(key: key);

  final ValueNotifier<double> _scrollRatio = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgct = ColorTween(
      begin: theme.backgroundColor.withOpacity(0.0),
      end: theme.backgroundColor.withOpacity(0.87),
    );
    final it = ColorTween(
      begin: theme.backgroundColor,
      end: theme.scaffoldBackgroundColor,
    );
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider<BangumiModel>(
        create: (_) => BangumiModel(bangumiId, cover),
        child: Builder(builder: (context) {
          final model = Provider.of<BangumiModel>(context, listen: false);
          return Scaffold(
            body: NotificationListener<ScrollUpdateNotification>(
              onNotification: (ScrollUpdateNotification notification) {
                final double offset = notification.metrics.pixels;
                if (offset >= 0) {
                  _scrollRatio.value = math.min(1.0, offset / 96);
                }
                return true;
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CacheImageProvider(cover),
                        ),
                      ),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaY: 16.0, sigmaX: 16.0),
                          child: ColoredBox(
                            color:
                                theme.scaffoldBackgroundColor.withOpacity(0.08),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: _buildList(theme, model),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _scrollRatio,
                      builder: (_, ratio, __) {
                        final bgc = bgct.transform(ratio < 0.2 ? 0 : ratio);
                        final ic = it.transform(ratio);
                        return _buildHeader(
                          context,
                          theme,
                          model,
                          ratio,
                          bgc,
                          ic,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    BangumiModel model,
    double ratio,
    Color? bgc,
    Color? ic,
  ) {
    final child = Container(
      decoration: BoxDecoration(color: bgc),
      padding: EdgeInsets.only(
        top: 12 + Screens.statusBarHeight,
        left: 16.0,
        right: 16.0,
        bottom: 12.0,
      ),
      child: Row(
        children: [
          CircleBackButton(color: ic),
          sizedBoxW16,
          Expanded(
            child: Opacity(
              opacity: ratio,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Selector<BangumiModel, String?>(
                      selector: (_, model) => model.bangumiDetail?.name,
                      shouldRebuild: (pre, next) => pre != next,
                      builder: (_, value, __) {
                        if (value == null) {
                          return sizedBox;
                        }
                        return Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle20B,
                        );
                      },
                    ),
                  ),
                  sizedBoxW12,
                  RippleTap(
                    onTap: () {
                      model.bangumiDetail?.shareString.share();
                    },
                    color: ic,
                    shape: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.share_rounded,
                        size: 16.0,
                      ),
                    ),
                  ),
                  sizedBoxW8,
                  RippleTap(
                    onTap: () {
                      model.changeSubscribe();
                    },
                    color: ic,
                    shape: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Selector<BangumiModel, bool>(
                        selector: (_, model) =>
                            model.bangumiDetail?.subscribed == true,
                        shouldRebuild: (pre, next) => pre != next,
                        builder: (_, subscribed, __) {
                          return Icon(
                            subscribed
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: subscribed ? Colors.redAccent : null,
                            size: 16.0,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
    return ratio <= 0.1
        ? child
        : ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 16.0, sigmaX: 16.0),
              child: child,
            ),
          );
  }

  Widget _buildList(
    final ThemeData theme,
    final BangumiModel model,
  ) {
    return Selector<BangumiModel, int>(
      selector: (_, model) => model.refreshFlag,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, _, __) {
        final detail = model.bangumiDetail;
        final notNull = detail != null;
        final subgroups = detail?.subgroupBangumis;
        final notEmpty = subgroups?.isNotEmpty == true;
        final items = [
          _buildTop(
            context,
            theme,
            model,
          ),
          if (notNull)
            _buildBase(
              theme,
              model.bangumiDetail!,
            ),
          if (notEmpty)
            _buildSubgroupTags(
              context,
              theme,
              model,
            ),
          if (notNull && detail.intro.isNotBlank)
            _buildIntro(
              theme,
              detail,
            ),
          if (notEmpty) ..._buildSubgroups(context, theme, model, subgroups!),
        ];
        return SmartRefresher(
          controller: model.refreshController,
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropMaterialHeader(
            backgroundColor: theme.secondary,
            color: theme.secondary.isDark ? Colors.white : Colors.black,
            distance: Screens.statusBarHeight + 42.0,
          ),
          onRefresh: model.load,
          child: WaterfallFlow(
            padding: edgeH16T96B48WithSafeHeight,
            gridDelegate:
                const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
                  minCrossAxisExtent: 400.0,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            children: items,
          ),
        );
      },
    );
  }

  Iterable<Widget> _buildSubgroups(
    final BuildContext context,
    final ThemeData theme,
    final BangumiModel model,
    final Map<String, SubgroupBangumi> subgroups,
  ) {
    return subgroups.values.map((e) {
      final length = e.records.length;
      return Container(
        decoration: BoxDecoration(color: theme.backgroundColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.name,
                      style: TextStyle(
                        color: theme.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0,
                        height: 1.25,
                      ),
                    ),
                  ),
                  RightArrowButton(
                    onTap: () {
                      _showSubgroupPanel(context, model, e.dataId);
                    },
                    color: theme.scaffoldBackgroundColor,
                  ),
                ],
              ),
            ),
            ListView.separated(
              itemCount: length > 4 ? 4 : length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, ind) {
                final record = e.records[ind];
                return RippleTap(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.recordDetail.name,
                      arguments: Routes.recordDetail.d(url: record.url),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          record.title,
                          style: textStyle14B500,
                        ),
                        sizedBoxH12,
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                record.publishAt,
                                style: theme.textTheme.caption,
                              ),
                            ),
                            sizedBoxW8,
                            TorrentButton(payload: record.torrent),
                            sizedBoxW8,
                            MagnetButton(payload: record.magnet),
                            sizedBoxW8,
                            ShareButton(payload: record.shareString),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) {
                return const Divider();
              },
            ),
            sizedBoxH24,
          ],
        ),
      );
    });
  }

  Widget _buildIntro(final ThemeData theme, final BangumiDetail detail) {
    return Container(
      width: double.infinity,
      padding: edge24,
      color: theme.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "概况简介",
            style: textStyle18B,
          ),
          sizedBoxH12,
          Text(
            detail.intro,
            textAlign: TextAlign.justify,
            softWrap: true,
            style: const TextStyle(
              fontSize: 15.0,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubgroupTags(
    final BuildContext context,
    final ThemeData theme,
    final BangumiModel model,
  ) {
    final subgroups =
        model.bangumiDetail?.subgroupBangumis.entries.toList(growable: false);
    return Container(
      width: double.infinity,
      padding: edge24,
      decoration: BoxDecoration(color: theme.backgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "字幕组",
            style: textStyle18B,
          ),
          sizedBoxH12,
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(subgroups!.length, (index) {
              final entry = subgroups[index];
              final groupName = entry.value.name;
              return Tooltip(
                message: groupName,
                child: RippleTap(
                  color: theme.secondary.withOpacity(0.1),
                  onTap: () {
                    _showSubgroupPanel(context, model, entry.key);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.secondary,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTop(
    final BuildContext context,
    final ThemeData theme,
    final BangumiModel model,
  ) {
    final Color accentTextColor =
        theme.secondary.isDark ? Colors.white : Colors.black;
    final Color primaryTextColor =
        theme.primary.isDark ? Colors.white : Colors.black;
    return Stack(
      fit: StackFit.loose,
      children: [
        Positioned.fill(
          child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 0.5,
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(color: theme.backgroundColor),
            ),
          ),
        ),
        Container(
          margin: edge24,
          child: Row(
            children: [
              _buildCover(cover, model),
              spacer,
              RippleTap(
                onTap: () {
                  model.bangumiDetail?.shareString.share();
                },
                color: theme.secondary,
                shape: const CircleBorder(),
                child: SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: Icon(
                    Icons.share_rounded,
                    color: accentTextColor,
                    size: 20.0,
                  ),
                ),
              ),
              sizedBoxW16,
              RippleTap(
                onTap: () {
                  model.changeSubscribe();
                },
                color: theme.primaryColor,
                shape: const CircleBorder(),
                child: SizedBox(
                  width: 48.0,
                  height: 48.0,
                  child: Selector<BangumiModel, bool>(
                    selector: (_, model) =>
                        model.bangumiDetail?.subscribed == true,
                    shouldRebuild: (pre, next) => pre != next,
                    builder: (_, subscribed, __) {
                      return Icon(
                        subscribed
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: primaryTextColor,
                        size: 24.0,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBase(final ThemeData theme, final BangumiDetail detail) {
    return Container(
      width: double.infinity,
      padding: edge24,
      decoration: BoxDecoration(color: theme.backgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.name,
            style: TextStyle(
              color: theme.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 18.0,
            ),
          ),
          sizedBoxH12,
          ...detail.more.entries.mapIndexed((index, e) {
            final child = Row(
              children: [
                Text(
                  "${e.key}：",
                  softWrap: true,
                  style: textStyle14,
                ),
                e.value.startsWith("http")
                    ? RippleTap(
                        onTap: () {
                          e.value.launchAppAndCopy();
                        },
                        child: Text(
                          "打开链接",
                          softWrap: true,
                          style: TextStyle(
                            color: theme.secondary,
                            height: 1.25,
                            fontSize: 14.0,
                          ),
                        ),
                      )
                    : Text(
                        e.value,
                        softWrap: true,
                        style: const TextStyle(
                          height: 1.25,
                          fontSize: 14.0,
                        ),
                      )
              ],
            );
            return index == detail.more.length - 1
                ? child
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: child,
                  );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCover(final String cover, final BangumiModel model) {
    return Image(
      image: CacheImageProvider(cover),
      width: 136.0,
      loadingBuilder: (_, child, event) {
        return event == null
            ? child
            : AspectRatio(
                aspectRatio: 3 / 4,
                child: Hero(
                  tag: heroTag,
                  child: Container(
                    padding: edge28,
                    child: Center(
                      child: SpinKitPumpingHeart(
                        duration: const Duration(milliseconds: 960),
                        itemBuilder: (_, __) => Image.asset(
                          "assets/mikan.png",
                        ),
                      ),
                    ),
                  ),
                ),
              );
      },
      errorBuilder: (_, __, ___) {
        return AspectRatio(
          aspectRatio: 3 / 4,
          child: Hero(
            tag: heroTag,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/mikan.png"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
                ),
              ),
            ),
          ),
        );
      },
      frameBuilder: (_, child, ___, ____) {
        return Hero(
          tag: heroTag,
          child: child,
        );
      },
    );
  }

  void _showSubgroupPanel(
    final BuildContext context,
    final BangumiModel model,
    final String dataId,
  ) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      topRadius: radius0,
      builder: (context) {
        return SubgroupBangumisFragment(bangumiModel: model, dataId: dataId);
      },
    );
  }
}
