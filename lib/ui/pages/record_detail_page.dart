import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/record_details.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:mikan_flutter/providers/models/record_detail_model.dart';
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
    final Color accentColor = Theme.of(context).accentColor;
    final Color backgroundColor = Theme.of(context).backgroundColor;
    final Color subtitleColor = Theme.of(context).textTheme.subtitle1.color;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color primaryTextColor =
        primaryColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
    final Color accentTextColor =
        accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
    final TextStyle titleTagStyle = TextStyle(
      fontSize: 12,
      height: 1.25,
      color: primaryTextColor,
    );
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => RecordDetailModel(this.url),
        child: Scaffold(
          body: Stack(
            children: [
              _buildBackground(backgroundColor),
              _buildLoading(backgroundColor),
              _buildContentWrapper(
                context,
                primaryColor,
                primaryTextColor,
                accentColor,
                accentTextColor,
                subtitleColor,
                backgroundColor,
                titleTagStyle,
              ),
              _buildHeadBar(context, backgroundColor),
            ],
          ),
        ),
      ),
    );
  }

  Positioned _buildHeadBar(BuildContext context, Color backgroundColor) {
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
              color: backgroundColor.withOpacity(0.87),
              minWidth: 0,
              padding: EdgeInsets.all(10.0),
              shape: CircleBorder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(final Color backgroundColor) {
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
                image: ExtendedNetworkImageProvider(recordDetail.cover),
              ),
            ),
            child: Selector<RecordDetailModel, Color>(
              selector: (_, model) => model.coverMainColor,
              shouldRebuild: (pre, next) => pre != next,
              builder: (_, bgColor, __) {
                final color = bgColor ?? backgroundColor;
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaY: 8.0, sigmaX: 8.0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 640),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, color],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentWrapper(
    final BuildContext context,
    final Color primaryColor,
    final Color primaryTextColor,
    final Color accentColor,
    final Color accentTextColor,
    final Color subtitleColor,
    final Color backgroundColor,
    final TextStyle titleTagStyle,
  ) {
    return Positioned.fill(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Selector<RecordDetailModel, RecordDetail>(
          selector: (_, model) => model.recordDetail,
          shouldRebuild: (pre, next) => pre != next,
          builder: (_, recordDetail, __) {
            if (recordDetail == null) {
              return Container();
            }
            return Column(
              children: [
                SizedBox(height: 160.0 + Sz.statusBarHeight),
                _buildRecordTop(
                  context,
                  primaryColor,
                  primaryTextColor,
                  accentColor,
                  accentTextColor,
                  backgroundColor,
                  recordDetail,
                ),
                _buildBangumiBase(
                  primaryColor,
                  accentColor,
                  subtitleColor,
                  backgroundColor,
                  titleTagStyle,
                  recordDetail,
                ),
                _buildRecordIntro(
                  accentColor,
                  backgroundColor,
                  recordDetail,
                ),
                SizedBox(height: Sz.navBarHeight + 36.0),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBangumiBase(
    final Color primaryColor,
    final Color accentColor,
    final Color subtitleColor,
    final Color backgroundColor,
    final TextStyle titleTagStyle,
    final RecordDetail recordDetail,
  ) {
    final List<String> tags = recordDetail.tags;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
        top: 8.0,
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
            backgroundColor.withOpacity(0.72),
            backgroundColor.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recordDetail.name.isNotBlank)
            Text(
              recordDetail.name,
              style: TextStyle(
                color: accentColor,
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
                      color: subtitleColor,
                    ),
                  ))
              .toList(),
          SizedBox(height: 8.0),
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
                          primaryColor,
                          primaryColor.withOpacity(0.56),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    child: Text(
                      tags[index],
                      style: titleTagStyle,
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLoading(final Color backgroundColor) {
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
    final Color primaryColor,
    final Color primaryTextColor,
    final Color accentColor,
    final Color accentTextColor,
    final Color backgroundColor,
    final RecordDetail recordDetail,
  ) {
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
                        backgroundColor.withOpacity(0.72),
                        backgroundColor.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(16.0),
                    ),
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
                      recordDetail.magnet.share();
                    },
                    child: Container(
                      width: 42.0,
                      height: 42.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withOpacity(0.78),
                            accentColor,
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
                      recordDetail.magnet.launchApp();
                      recordDetail.magnet.copy();
                    },
                    child: Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withOpacity(0.78),
                            primaryColor,
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
    final Color accentColor,
    final Color backgroundColor,
    final RecordDetail recordDetail,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
      ),
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor.withOpacity(0.72),
            backgroundColor.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
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
          SizedBox(height: 8.0),
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
      final BuildContext context, final RecordDetail recordDetail) {
    return ExtendedImage.network(
      recordDetail.cover,
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
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
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
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
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
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
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
                child: recordDetail.subscribed
                    ? SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: IconButton(
                          tooltip: "取消订阅",
                          padding: EdgeInsets.all(2.0),
                          icon: Icon(
                            FluentIcons.heart_24_filled,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            context.read<IndexModel>().subscribeBangumi(Bangumi(
                                  id: recordDetail.id,
                                  subscribed: recordDetail.subscribed,
                                ));
                          },
                        ),
                      )
                    : Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.black38,
                        ),
                        child: IconButton(
                          tooltip: "订阅",
                          padding: EdgeInsets.all(2.0),
                          iconSize: 16.0,
                          icon: Icon(
                            FluentIcons.heart_24_regular,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            context.read<IndexModel>().subscribeBangumi(Bangumi(
                                  id: recordDetail.id,
                                  subscribed: recordDetail.subscribed,
                                ));
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(final String url) {
    return ExtendedImage.network(
      url,
      clearMemoryCacheWhenDispose: true,
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
