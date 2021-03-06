import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/record_details.dart';
import 'package:mikan_flutter/providers/view_models/op_model.dart';
import 'package:mikan_flutter/providers/view_models/record_detail_model.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "record-detail",
  routeName: "record-detail",
  argumentImports: [
    "import 'package:mikan_flutter/model/year_season.dart';",
    "import 'package:mikan_flutter/model/season_gallery.dart';",
    "import 'package:flutter/material.dart';",
  ],
)
@immutable
class RecordDetailPage extends StatelessWidget {
  final String url;

  const RecordDetailPage({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => RecordDetailModel(this.url),
        child: Scaffold(
          body: Stack(
            children: [
              _buildBackground(theme),
              _buildLoading(),
              _buildContentWrapper(theme),
              _buildHeadBar(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadBar(
    final BuildContext context,
    final ThemeData theme,
  ) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: Sz.statusBarHeight + 12.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Row(
          children: [
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(FluentIcons.chevron_left_24_regular),
              color: theme.backgroundColor.withOpacity(0.87),
              minWidth: 0,
              padding: EdgeInsets.all(10.0),
              shape: CircleBorder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(final ThemeData theme) {
    return Positioned.fill(
      child: Selector<RecordDetailModel, RecordDetail>(
        selector: (_, model) => model.recordDetail,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, recordDetail, __) {
          if (recordDetail == null) return Container();
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(recordDetail.cover),
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 10.0, sigmaX: 10.0),
              child: Selector<RecordDetailModel, Color>(
                selector: (_, model) => model.coverMainColor,
                shouldRebuild: (pre, next) => pre != next,
                builder: (_, bgColor, __) {
                  final color = bgColor ?? theme.backgroundColor;
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 640),
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
    );
  }

  Widget _buildContentWrapper(final ThemeData theme) {
    return Positioned.fill(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Selector<RecordDetailModel, RecordDetail>(
          selector: (context, model) => model.recordDetail,
          shouldRebuild: (pre, next) => pre != next,
          builder: (context, recordDetail, __) {
            if (recordDetail == null) {
              return Container();
            }
            return Column(
              children: [
                SizedBox(height: 160.0 + Sz.statusBarHeight),
                _buildRecordTop(
                  context,
                  theme,
                  recordDetail,
                ),
                _buildBangumiBase(
                  theme,
                  recordDetail,
                ),
                _buildRecordIntro(theme, recordDetail),
                SizedBox(height: Sz.navBarHeight + 36.0),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBangumiBase(
    final ThemeData theme,
    final RecordDetail recordDetail,
  ) {
    final List<String> tags = recordDetail.tags;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 12.0,
        top: 12.0,
      ),
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
        top: 24.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            theme.backgroundColor.withOpacity(0.72),
            theme.backgroundColor.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recordDetail.name.isNotBlank)
            Text(
              recordDetail.name,
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
          if (recordDetail.name.isNotBlank) SizedBox(height: 8.0),
          Text(
            recordDetail.title,
            style: TextStyle(
              fontSize: 14.0,
              height: 1.25,
            ),
          ),
          Divider(),
          ...recordDetail.more.entries
              .map((e) => Text(
                    "${e.key}: ${e.value}",
                    softWrap: true,
                    style: TextStyle(
                      height: 1.6,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.subtitle1.color,
                    ),
                  ))
              .toList(),
          SizedBox(height: 12.0),
          if (!tags.isNullOrEmpty)
            Wrap(
              children: [
                ...List.generate(tags.length, (index) {
                  return Container(
                    margin: EdgeInsets.only(
                      right: 4.0,
                      bottom: 4.0,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.56),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    child: Text(
                      tags[index],
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.25,
                        color: theme.primaryColor.computeLuminance() < 0.5
                            ? Colors.white
                            : Colors.black,
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

  Widget _buildLoading() {
    return Positioned.fill(
      child: Selector<RecordDetailModel, bool>(
        selector: (_, model) => model.loading,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, loading, child) {
          if (loading) return child;
          return Container();
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(child: CupertinoActivityIndicator()),
        ),
      ),
    );
  }

  Widget _buildRecordTop(
    final BuildContext context,
    final ThemeData theme,
    final RecordDetail recordDetail,
  ) {
    final Color accentTextColor = theme.accentColor.computeLuminance() < 0.5
        ? Colors.white
        : Colors.black;
    final Color primaryTextColor = theme.primaryColor.computeLuminance() < 0.5
        ? Colors.white
        : Colors.black;
    return Column(
      children: [
        Stack(
          fit: StackFit.loose,
          children: [
            Positioned.fill(
              left: 16.0,
              right: 16.0,
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
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
              child: Row(
                children: [
                  _buildBangumiCover(context, recordDetail),
                  Spacer(),
                  MaterialButton(
                    onPressed: () {
                      recordDetail.shareString.share();
                    },
                    child: Container(
                      width: 42.0,
                      height: 42.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.accentColor.withOpacity(0.78),
                            theme.accentColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Icon(
                        FluentIcons.share_24_regular,
                        color: accentTextColor,
                      ),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minWidth: 0,
                    color: accentTextColor,
                    padding: EdgeInsets.zero,
                    shape: CircleBorder(),
                  ),
                  SizedBox(width: 16.0),
                  MaterialButton(
                    onPressed: () {
                      recordDetail.magnet.launchAppAndCopy();
                    },
                    child: Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withOpacity(0.78),
                            theme.primaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Icon(
                        FluentIcons.clipboard_link_24_regular,
                        color: primaryTextColor,
                      ),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minWidth: 0,
                    color: primaryTextColor,
                    padding: EdgeInsets.zero,
                    shape: CircleBorder(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordIntro(
    final ThemeData theme,
    final RecordDetail recordDetail,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 12.0,
      ),
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.backgroundColor.withOpacity(0.72),
            theme.backgroundColor.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "概况简介",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          SizedBox(height: 12.0),
          HtmlWidget(
            recordDetail.intro,
            customWidgetBuilder: (element) {
              if (element.localName == "img") {
                final String src = element.attributes["src"];
                if (src.isNotBlank) {
                  return _buildImageWidget(src);
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
      image: CachedNetworkImageProvider(recordDetail.cover),
      width: 136.0,
      shape: BoxShape.rectangle,
      loadStateChanged: (state) {
        Widget child;
        if (state.extendedImageLoadState == LoadState.loading) {
          child = Container(
            padding: EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withOpacity(0.6),
                ),
              ],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: SpinKitPumpingHeart(
                duration: Duration(milliseconds: 960),
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
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: ExtendedAssetImageProvider("assets/mikan.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
              ),
            ),
          );
        } else if (state.extendedImageLoadState == LoadState.completed) {
          recordDetail.coverSize = Size(
            state.extendedImageInfo.image.width.toDouble(),
            state.extendedImageInfo.image.height.toDouble(),
          );
          child = Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withAlpha(24),
                )
              ],
              borderRadius: BorderRadius.circular(8.0),
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
              : recordDetail.coverSize.width / recordDetail.coverSize.height,
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
      selector: (_, model) => model.recordDetail?.subscribed,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, subscribed, __) {
        final Widget child = subscribed
            ? IconButton(
                tooltip: "取消订阅",
                padding: EdgeInsets.all(4.0),
                iconSize: 20.0,
                icon: Icon(
                  FluentIcons.heart_24_filled,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  context.read<OpModel>().subscribeBangumi(
                    recordDetail.id,
                    recordDetail.subscribed,
                    onSuccess: () {
                      recordDetail.subscribed = !recordDetail.subscribed;
                      context.read<RecordDetailModel>().notifyListeners();
                    },
                    onError: (msg) {
                      "订阅失败：$msg".toast();
                    },
                  );
                },
              )
            : IconButton(
                tooltip: "订阅",
                padding: EdgeInsets.all(4.0),
                iconSize: 20.0,
                icon: Icon(
                  FluentIcons.heart_24_regular,
                  color: Colors.blueGrey,
                ),
                onPressed: () {
                  context.read<OpModel>().subscribeBangumi(
                    recordDetail.id,
                    recordDetail.subscribed,
                    onSuccess: () {
                      recordDetail.subscribed = !recordDetail.subscribed;
                      context.read<RecordDetailModel>().notifyListeners();
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
      image: CachedNetworkImageProvider(url),
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
        return null;
      },
    );
  }
}
