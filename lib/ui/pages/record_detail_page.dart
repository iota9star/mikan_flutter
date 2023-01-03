import 'dart:math' as math;
import 'dart:ui';

import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/record_details.dart';
import 'package:mikan_flutter/providers/op_model.dart';
import 'package:mikan_flutter/providers/record_detail_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/icon_button.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@FFRoute(
  name: "record-detail",
  routeName: "/record/detail",
  argumentImports: [
    "import 'package:mikan_flutter/model/year_season.dart';",
    "import 'package:mikan_flutter/model/season_gallery.dart';",
  ],
)
@immutable
class RecordDetailPage extends StatelessWidget {
  final String url;

  RecordDetailPage({Key? key, required this.url}) : super(key: key);
  final ValueNotifier<double> _scrollRatio = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
      child: ChangeNotifierProvider(
        create: (_) => RecordDetailModel(url),
        child: Builder(builder: (context) {
          final model = Provider.of<RecordDetailModel>(context, listen: false);
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
                  _buildBackground(theme),
                  _buildContentWrapper(theme, model),
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
    RecordDetailModel model,
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
                    child: Selector<RecordDetailModel, String?>(
                      selector: (_, model) => model.recordDetail?.name,
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
                      model.recordDetail?.shareString.share();
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
                  sizedBoxW12,
                  RippleTap(
                    onTap: () {
                      model.recordDetail?.magnet.launchAppAndCopy();
                    },
                    color: ic,
                    shape: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.downloading_rounded,
                        size: 16.0,
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
    return ratio < 0.1
        ? child
        : ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: child,
            ),
          );
  }

  Widget _buildBackground(final ThemeData theme) {
    return Positioned.fill(
      child: Selector<RecordDetailModel, RecordDetail?>(
        selector: (_, model) => model.recordDetail,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, recordDetail, __) {
          if (recordDetail == null) return sizedBox;
          Widget child = ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 16.0, sigmaX: 16.0),
              child: ColoredBox(
                color: theme.scaffoldBackgroundColor.withOpacity(0.08),
              ),
            ),
          );
          if (recordDetail.cover.endsWith("noimageavailble_icon.png")) {
            return child;
          }
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CacheImageProvider(recordDetail.cover),
              ),
            ),
            child: child,
          );
        },
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
              distance: Screens.statusBarHeight + 42.0,
            ),
            onRefresh: model.refresh,
            child: WaterfallFlow(
              padding: edgeH16T96B48WithSafeHeight,
              gridDelegate:
                  const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
                    minCrossAxisExtent: 400.0,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              children: recordDetail == null
                  ? []
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
      decoration: BoxDecoration(color: theme.backgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recordDetail.name.isNotBlank)
            Text(
              recordDetail.name,
              style: TextStyle(
                color: theme.secondary,
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
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
            style: const TextStyle(
                      height: 1.6,
                      fontSize: 14.0,
                    ),
                  ))
              .toList(),
          sizedBoxH12,
          if (!tags.isNullOrEmpty)
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: [
                ...List.generate(
                  tags.length,
                  (index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(color: theme.primary),
                      child: Text(
                        tags[index],
                        style: TextStyle(
                          fontSize: 10.0,
                          height: 1.25,
                          color: theme.primary.isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
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
    final accentTextColor =
        theme.secondary.isDark ? Colors.white : Colors.black;
    final primaryTextColor = theme.primary.isDark ? Colors.white : Colors.black;
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
                  color: theme.backgroundColor,
                ),
              ),
            ),
            Container(
              margin: edge24,
              child: Row(
                children: [
                  _buildBangumiCover(context, detail),
                  spacer,
                  RippleTap(
                    onTap: () {
                      detail.shareString.share();
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
                      detail.magnet.launchAppAndCopy();
                    },
                    color: theme.primary,
                    shape: const CircleBorder(),
                    child: SizedBox(
                      width: 48.0,
                      height: 48.0,
                      child: Icon(
                        Icons.downloading_rounded,
                        color: primaryTextColor,
                        size: 24.0,
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
      decoration: BoxDecoration(color: theme.backgroundColor),
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
    return Image(
      image: CacheImageProvider(recordDetail.cover),
      width: 136.0,
      loadingBuilder: (_, child, event) {
        return event == null
            ? child
            : Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 4,
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
                  _buildSubscribeBtn(context, recordDetail),
                ],
              );
      },
      errorBuilder: (_, __, ___) {
        return Stack(
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
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
            Positioned(
              child: _buildSubscribeBtn(context, recordDetail),
            ),
          ],
        );
      },
      frameBuilder: (_, child, ___, ____) {
        return Stack(
          children: [
            child,
            Positioned(
              child: _buildSubscribeBtn(context, recordDetail),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubscribeBtn(BuildContext context, RecordDetail recordDetail) {
    return Selector<RecordDetailModel, bool>(
      selector: (_, model) => model.recordDetail?.subscribed ?? false,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, subscribed, __) {
        return subscribed
            ? Tooltip(
                message: "取消订阅",
                child: RippleTap(
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.redAccent,
                      size: 24.0,
                    ),
                  ),
                  onTap: () {
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
                ),
              )
            : Tooltip(
                message: "订阅",
                child: RippleTap(
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.redAccent,
                      size: 24.0,
                    ),
                  ),
                  onTap: () {
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
                ),
              );
      },
    );
  }

  Widget _buildImageWidget(final String url) {
    final placeholder = AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        color: Colors.grey.withOpacity(0.24),
        child: Center(
          child: Image.asset(
            "assets/mikan.png",
            width: 56.0,
          ),
        ),
      ),
    );
    return Image(
      image: CacheImageProvider(url),
      loadingBuilder: (_, child, event) {
        return event == null ? child : placeholder;
      },
      errorBuilder: (_, __, ___) {
        return placeholder;
      },
    );
  }
}
