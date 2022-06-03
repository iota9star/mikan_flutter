import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/record_details.dart';
import 'package:mikan_flutter/providers/op_model.dart';
import 'package:mikan_flutter/providers/record_detail_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@FFRoute(
  name: "record-detail",
  routeName: "/record-detail",
  argumentImports: [
    "import 'package:mikan_flutter/model/year_season.dart';",
    "import 'package:mikan_flutter/model/season_gallery.dart';",
  ],
)
@immutable
class RecordDetailPage extends StatelessWidget {
  final String url;

  const RecordDetailPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => RecordDetailModel(url),
        child: Builder(builder: (context) {
          final model = Provider.of<RecordDetailModel>(context, listen: false);
          return Scaffold(
            body: Stack(
              children: [
                _buildBackground(theme),
                _buildContentWrapper(theme, model),
                _buildHeader(context, theme),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(
    final BuildContext context,
    final ThemeData theme,
  ) {
    return Positioned(
      top: 12.0 + Screen.statusBarHeight,
      left: 16.0,
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
    );
  }

  Widget _buildBackground(final ThemeData theme) {
    return Positioned.fill(
      child: ClipRect(
        child: Selector<RecordDetailModel, RecordDetail?>(
          selector: (_, model) => model.recordDetail,
          shouldRebuild: (pre, next) => pre != next,
          builder: (_, recordDetail, __) {
            if (recordDetail == null) return sizedBox;
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: FastCacheImage(recordDetail.cover),
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaY: 10.0, sigmaX: 10.0),
                child: Selector<RecordDetailModel, Color?>(
                  selector: (_, model) => model.coverMainColor,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (_, bgColor, __) {
                    final color = bgColor ?? theme.backgroundColor;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 640),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, color],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContentWrapper(
    final ThemeData theme,
    final RecordDetailModel model,
  ) {
    return Positioned.fill(
      child: Selector<RecordDetailModel, RecordDetail?>(
        selector: (context, model) => model.recordDetail,
        shouldRebuild: (pre, next) => pre != next,
        builder: (context, recordDetail, __) {
          return SmartRefresher(
            controller: model.refreshController,
            enablePullDown: true,
            enablePullUp: false,
            header: WaterDropMaterialHeader(
              backgroundColor: theme.secondary,
              color: theme.secondary.isDark ? Colors.white : Colors.black,
              distance: Screen.statusBarHeight + 42.0,
            ),
            onRefresh: model.refresh,
            child: WaterfallFlow(
              padding: edgeH16T136B24WithStatusBar,
              gridDelegate:
                  const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
                minCrossAxisExtent: 400.0,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
              ),
              physics: const BouncingScrollPhysics(),
              children: recordDetail == null
                  ? [sizedBox]
                  : [
                      _buildTop(
                        context,
                        theme,
                        recordDetail,
                      ),
                      _buildBase(
                        theme,
                        recordDetail,
                      ),
                      _buildIntro(theme, recordDetail),
                    ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBase(
    final ThemeData theme,
    final RecordDetail recordDetail,
  ) {
    final List<String> tags = recordDetail.tags;
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
          if (recordDetail.name.isNotBlank)
            Text(
              recordDetail.name,
              style: TextStyle(
                color: theme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          if (recordDetail.name.isNotBlank) sizedBoxH8,
          Text(
            recordDetail.title,
            style: textStyle14B500,
          ),
          const Divider(),
          ...recordDetail.more.entries
              .map((e) => Text(
                    "${e.key}: ${e.value}",
                    softWrap: true,
                    style: TextStyle(
                      height: 1.6,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.subtitle1?.color,
                    ),
                  ))
              .toList(),
          sizedBoxH12,
          if (!tags.isNullOrEmpty)
            Wrap(
              children: [
                ...List.generate(tags.length, (index) {
                  return Container(
                    margin: const EdgeInsets.only(
                      right: 4.0,
                      bottom: 4.0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primary,
                          theme.primary.withOpacity(0.56),
                        ],
                      ),
                      borderRadius: borderRadius2,
                    ),
                    child: Text(
                      tags[index],
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.25,
                        color:
                            theme.primary.isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTop(
    final BuildContext context,
    final ThemeData theme,
    final RecordDetail detail,
  ) {
    final Color accentTextColor =
        theme.secondary.isDark ? Colors.white : Colors.black;
    final Color primaryTextColor =
        theme.primary.isDark ? Colors.white : Colors.black;
    return Column(
      children: [
        Stack(
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
                  _buildBangumiCover(context, detail),
                  spacer,
                  MaterialButton(
                    onPressed: () {
                      detail.shareString.share();
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
                      detail.magnet.launchAppAndCopy();
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
                      child: Icon(
                        FluentIcons.clipboard_link_24_filled,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntro(
    final ThemeData theme,
    final RecordDetail recordDetail,
  ) {
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
          HtmlWidget(
            recordDetail.intro,
            customWidgetBuilder: (element) {
              if (element.localName == "img") {
                final String? src = element.attributes["src"];
                if (src.isNotBlank) {
                  return _buildImageWidget(src!);
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBangumiCover(
    final BuildContext context,
    final RecordDetail recordDetail,
  ) {
    return ExtendedImage(
      image: FastCacheImage(recordDetail.cover),
      width: 136.0,
      shape: BoxShape.rectangle,
      loadStateChanged: (state) {
        Widget child;
        if (state.extendedImageLoadState == LoadState.loading) {
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
        } else if (state.extendedImageLoadState == LoadState.failed) {
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
          recordDetail.coverSize = Size(
            state.extendedImageInfo!.image.width.toDouble(),
            state.extendedImageInfo!.image.height.toDouble(),
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
                image: state.imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        return AspectRatio(
          aspectRatio: recordDetail.coverSize == null
              ? 1
              : recordDetail.coverSize!.width / recordDetail.coverSize!.height,
          child: Stack(
            children: [
              Positioned.fill(child: child),
              Positioned(
                child: _buildSubscribeBtn(context, recordDetail),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubscribeBtn(BuildContext context, RecordDetail recordDetail) {
    return Selector<RecordDetailModel, bool>(
      selector: (_, model) => model.recordDetail?.subscribed ?? false,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, subscribed, __) {
        final Widget child = subscribed
            ? IconButton(
                tooltip: "取消订阅",
                padding: edge4,
                iconSize: 20.0,
                icon: const Icon(
                  FluentIcons.heart_24_filled,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  context.read<OpModel>().subscribeBangumi(
                    recordDetail.id,
                    recordDetail.subscribed,
                    onSuccess: () {
                      recordDetail.subscribed = !recordDetail.subscribed;
                      context.read<RecordDetailModel>().subscribeChanged();
                    },
                    onError: (msg) {
                      "订阅失败：$msg".toast();
                    },
                  );
                },
              )
            : IconButton(
                tooltip: "订阅",
                padding: edge4,
                iconSize: 20.0,
                icon: Icon(
                  FluentIcons.heart_24_regular,
                  color: Colors.redAccent.shade100,
                ),
                onPressed: () {
                  context.read<OpModel>().subscribeBangumi(
                    recordDetail.id,
                    recordDetail.subscribed,
                    onSuccess: () {
                      recordDetail.subscribed = !recordDetail.subscribed;
                      context.read<RecordDetailModel>().subscribeChanged();
                    },
                    onError: (msg) {
                      "订阅失败：$msg".toast();
                    },
                  );
                },
              );
        return SizedBox(
          width: 28.0,
          height: 28.0,
          child: child,
        );
      },
    );
  }

  Widget _buildImageWidget(final String url) {
    return ExtendedImage(
      image: FastCacheImage(url),
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
          case LoadState.failed:
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                width: double.infinity,
                color: Colors.grey.withOpacity(0.24),
                child: Center(
                  child: ExtendedImage.asset(
                    "assets/mikan.png",
                    width: 56.0,
                  ),
                ),
              ),
            );
          case LoadState.completed:
            return null;
        }
      },
    );
  }
}
