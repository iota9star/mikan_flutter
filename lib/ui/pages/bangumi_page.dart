import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi_details.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/bangumi_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/fragments/subgroup_bangumis_fragment.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';
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

  const BangumiPage({
    Key? key,
    required this.bangumiId,
    required this.cover,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider<BangumiModel>(
        create: (_) => BangumiModel(bangumiId, cover),
        child: Builder(builder: (context) {
          final model = Provider.of<BangumiModel>(context, listen: false);
          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CacheImageProvider(cover),
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaY: 8.0, sigmaX: 8.0),
                      child: ColoredBox(
                        color: theme.scaffoldBackgroundColor.withOpacity(0.08),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: _buildList(theme, model),
                ),
                Positioned(
                  left: 16.0,
                  top: 12.0 + Screen.statusBarHeight,
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    color: theme.backgroundColor,
                    minWidth: 32.0,
                    padding: EdgeInsets.zero,
                    shape: circleShape,
                    child: const Icon(
                      FluentIcons.chevron_left_24_regular,
                      size: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
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
            distance: Screen.statusBarHeight + 42.0,
          ),
          onRefresh: model.load,
          child: WaterfallFlow(
            padding: edgeH16T136B24WithStatusBar,
            physics: const BouncingScrollPhysics(),
            gridDelegate:
                const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
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
        padding: edge24,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.backgroundColor.withOpacity(0.72),
              theme.backgroundColor.withOpacity(0.9),
            ],
          ),
          borderRadius: borderRadius16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    e.name,
                    style: TextStyle(
                      color: theme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      height: 1.25,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _showSubgroupPanel(context, model, e.dataId);
                    },
                    child: Icon(
                      FluentIcons.chevron_right_24_regular,
                      size: 20.0,
                      color: theme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            sizedBoxH24,
            ListView.separated(
              itemCount: length > 4 ? 4 : length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, ind) {
                final RecordItem record = e.records[ind];
                return TapScaleContainer(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.recordDetail.name,
                      arguments: Routes.recordDetail.d(url: record.url),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        record.title,
                        style: textStyle15B500,
                      ),
                      sizedBoxH12,
                      Row(
                        children: <Widget>[
                          Text(
                            record.publishAt,
                            style: textStyle12,
                          ),
                          spacer,
                          SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                record.torrent.launchAppAndCopy();
                              },
                              child: Icon(
                                FluentIcons.arrow_download_24_filled,
                                size: 20.0,
                                color: theme.secondary,
                              ),
                            ),
                          ),
                          sizedBoxW16,
                          SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                record.magnet.launchAppAndCopy();
                              },
                              child: Icon(
                                FluentIcons.clipboard_link_24_filled,
                                size: 20.0,
                                color: theme.secondary,
                              ),
                            ),
                          ),
                          sizedBoxW16,
                          SizedBox(
                            width: 20.0,
                            height: 20.0,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                record.shareString.share();
                              },
                              child: Icon(
                                FluentIcons.share_24_filled,
                                size: 20.0,
                                color: theme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) {
                return const Padding(
                  padding: edgeV8,
                  child: Divider(),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildIntro(final ThemeData theme, final BangumiDetail detail) {
    return Container(
      width: double.infinity,
      padding: edge24,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.backgroundColor.withOpacity(0.72),
            theme.backgroundColor.withOpacity(0.9),
          ],
        ),
        borderRadius: borderRadius16,
      ),
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
    final subgroups = model.bangumiDetail?.subgroupBangumis.entries;
    return Container(
      width: double.infinity,
      padding: edge24,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.backgroundColor.withOpacity(0.72),
            theme.backgroundColor.withOpacity(0.9),
          ],
        ),
        borderRadius: borderRadius16,
      ),
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
              final entry = subgroups.elementAt(index);
              final String groupName = entry.value.name;
              return ActionChip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                tooltip: groupName,
                label: Text(
                  groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.secondary,
                  ),
                ),
                backgroundColor: theme.secondary.withOpacity(0.18),
                onPressed: () {
                  _showSubgroupPanel(context, model, entry.key);
                },
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.backgroundColor.withOpacity(0.72),
                    theme.backgroundColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: borderRadius16,
              ),
            ),
          ),
        ),
        Container(
          margin: edge24,
          child: Row(
            children: [
              _buildCover(cover, model),
              spacer,
              MaterialButton(
                onPressed: () {
                  model.bangumiDetail?.shareString.share();
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: 0,
                color: accentTextColor,
                padding: EdgeInsets.zero,
                shape: circleShape,
                child: Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.secondary.withOpacity(0.78),
                        theme.secondary,
                      ],
                    ),
                    borderRadius: borderRadius24,
                  ),
                  child: Icon(
                    FluentIcons.share_24_filled,
                    color: accentTextColor,
                  ),
                ),
              ),
              sizedBoxW16,
              MaterialButton(
                onPressed: () {
                  model.changeSubscribe();
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minWidth: 0,
                color: primaryTextColor,
                padding: EdgeInsets.zero,
                shape: circleShape,
                child: Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primary.withOpacity(0.78),
                        theme.primary,
                      ],
                    ),
                    borderRadius: borderRadius24,
                  ),
                  child: Selector<BangumiModel, bool>(
                    selector: (_, model) =>
                        model.bangumiDetail?.subscribed == true,
                    shouldRebuild: (pre, next) => pre != next,
                    builder: (_, subscribed, __) {
                      return Icon(
                        subscribed
                            ? FluentIcons.heart_24_filled
                            : FluentIcons.heart_24_regular,
                        color: primaryTextColor,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.backgroundColor.withOpacity(0.72),
            theme.backgroundColor.withOpacity(0.9),
          ],
        ),
        borderRadius: borderRadius16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.name,
            style: TextStyle(
              color: theme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          sizedBoxH12,
          ...detail.more.entries.map((e) {
            return Row(
              children: [
                Text(
                  "${e.key}：",
                  softWrap: true,
                  style: const TextStyle(
                    height: 1.8,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                e.value.startsWith("http")
                    ? InkWell(
                        onTap: () {
                          e.value.launchAppAndCopy();
                        },
                        child: Text(
                          "打开链接",
                          softWrap: true,
                          style: TextStyle(
                            color: theme.secondary,
                            height: 1.8,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Text(
                        e.value,
                        softWrap: true,
                        style: const TextStyle(
                          height: 1.8,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCover(final String cover, final BangumiModel model) {
    return ExtendedImage(
      image: CacheImageProvider(cover),
      width: 136.0,
      shape: BoxShape.rectangle,
      loadStateChanged: (ExtendedImageState value) {
        Widget child;
        if (value.extendedImageLoadState == LoadState.loading) {
          child = Container(
            padding: edge28,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withOpacity(0.6),
                ),
              ],
              borderRadius: borderRadius8,
            ),
            child: Center(
              child: SpinKitPumpingHeart(
                duration: const Duration(milliseconds: 960),
                itemBuilder: (_, __) => ExtendedImage.asset(
                  "assets/mikan.png",
                ),
              ),
            ),
          );
        } else if (value.extendedImageLoadState == LoadState.failed) {
          child = Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withAlpha(24),
                )
              ],
              borderRadius: borderRadius8,
              image: const DecorationImage(
                image: ExtendedAssetImageProvider("assets/mikan.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
              ),
            ),
          );
        } else {
          model.coverSize = Size(
            value.extendedImageInfo!.image.width.toDouble(),
            value.extendedImageInfo!.image.height.toDouble(),
          );
          child = Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withAlpha(24),
                )
              ],
              borderRadius: borderRadius8,
              image: DecorationImage(
                image: value.imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        return AspectRatio(
          aspectRatio: model.coverSize == null
              ? 1
              : model.coverSize!.width / model.coverSize!.height,
          child: Hero(
            tag: heroTag,
            child: child,
          ),
        );
      },
    );
  }

  _showSubgroupPanel(
    final BuildContext context,
    final BangumiModel model,
    final String dataId,
  ) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      topRadius: radius16,
      builder: (context) {
        return SubgroupBangumisFragment(bangumiModel: model, dataId: dataId);
      },
    );
  }
}
