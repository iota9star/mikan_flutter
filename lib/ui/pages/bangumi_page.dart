import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/bangumi_details.dart';
import 'package:mikan_flutter/model/subgroup_bangumi.dart';
import 'package:mikan_flutter/providers/bangumi_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_subgroup_fragment.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "bangumi",
  routeName: "bangumi",
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
        create: (_) => BangumiModel(this.bangumiId, this.cover),
        child: Builder(builder: (context) {
          final BangumiModel bangumiModel =
              Provider.of<BangumiModel>(context, listen: false);
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: ExtendedNetworkImageProvider(this.cover),
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaY: 10.0, sigmaX: 10.0),
                      child: Selector<BangumiModel, Color?>(
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
                  ),
                ),
                Positioned.fill(
                  child: CustomScrollView(
                    physics: BouncingScrollPhysics(),
                    slivers: [
                      SliverPinnedToBoxAdapter(
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
                                child:
                                    Icon(FluentIcons.chevron_left_24_regular),
                                color: theme.backgroundColor.withOpacity(0.87),
                                minWidth: 0,
                                padding: EdgeInsets.all(10.0),
                                shape: CircleBorder(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 98.0),
                            _buildBangumiTop(
                              theme,
                              this.cover,
                              bangumiModel,
                            ),
                            _buildLoading(theme),
                            _buildBangumiBase(
                              theme,
                              this.cover,
                            ),
                            _buildBangumiSubgroups(theme, bangumiModel),
                            _buildBangumiIntro(theme),
                            SizedBox(height: Sz.navBarHeight + 36.0)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoading(final ThemeData theme) {
    return Selector<BangumiModel, bool>(
      selector: (_, model) => model.loading,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, loading, __) {
        if (loading) {
          return Container(
            width: double.infinity,
            height: 240.0,
            margin: edgeH16V8,
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
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        return sizedBox;
      },
    );
  }

  Widget _buildBangumiIntro(final ThemeData theme) {
    return Selector<BangumiModel, BangumiDetail?>(
      selector: (_, model) => model.bangumiDetail,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, bangumiDetail, _) {
        if (bangumiDetail == null || bangumiDetail.intro.isNullOrBlank) {
          return const SizedBox();
        }
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 12.0,
          ),
          padding: const EdgeInsets.all(24.0),
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
                style: textStyle20B,
              ),
              SizedBox(height: 12.0),
              Text(
                bangumiDetail.intro ?? "",
                textAlign: TextAlign.justify,
                softWrap: true,
                style: TextStyle(
                  fontSize: 16.0,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBangumiSubgroups(
    final ThemeData theme,
    final BangumiModel bangumiModel,
  ) {
    return Selector<BangumiModel, List<SubgroupBangumi>?>(
      selector: (_, model) => model.bangumiDetail?.subgroupBangumis,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, subgroups, __) {
        if (subgroups.isNullOrEmpty) {
          return const SizedBox();
        }
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
          padding: const EdgeInsets.all(24.0),
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
                "字幕组",
                style: textStyle20B,
              ),
              SizedBox(height: 12.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(subgroups!.length, (subgroupIndex) {
                  final String groupName = subgroups[subgroupIndex].name;
                  return ActionChip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    tooltip: groupName,
                    label: Text(
                      groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.accentColor,
                      ),
                    ),
                    backgroundColor: theme.accentColor.withOpacity(0.18),
                    onPressed: () {
                      context.read<BangumiModel>().selectedSubgroupId =
                          subgroups[subgroupIndex].dataId;
                      _showSubgroupPanel(context, bangumiModel);
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBangumiTop(
    final ThemeData theme,
    final String cover,
    final BangumiModel bangumiModel,
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
                  _buildBangumiCover(cover, bangumiModel),
                  // Spacer(flex: 3),
                  // MaterialButton(
                  //   onPressed: () {},
                  //   child: Icon(FluentIcons.thumb_like_24_filled),
                  //   color: Colors.pinkAccent,
                  //   padding: EdgeInsets.all(12.0),
                  //   minWidth: 0,
                  //   shape: CircleBorder(),
                  // ),
                  // Spacer(),
                  // MaterialButton(
                  //   onPressed: () {},
                  //   child: Icon(FluentIcons.star_24_filled),
                  //   color: Colors.blueAccent,
                  //   minWidth: 0,
                  //   padding: EdgeInsets.all(16.0),
                  //   shape: CircleBorder(),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBangumiBase(
    final ThemeData theme,
    final String cover,
  ) {
    return Selector<BangumiModel, BangumiDetail?>(
      selector: (_, model) => model.bangumiDetail,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, bangumiDetail, _) {
        if (bangumiDetail == null) {
          return const SizedBox();
        }
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 12.0,
            top: 12.0,
          ),
          padding: const EdgeInsets.only(
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
              Text(
                bangumiDetail.name,
                style: TextStyle(
                  color: theme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              SizedBox(height: 12.0),
              ...bangumiDetail.more.entries
                  .map((e) => Text(
                        "${e.key}: ${e.value}",
                        softWrap: true,
                        style: TextStyle(
                          height: 1.6,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.subtitle1?.color,
                        ),
                      ))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBangumiCover(
    final String cover,
    final BangumiModel bangumiModel,
  ) {
    return ExtendedImage(
      image: ExtendedNetworkImageProvider(cover),
      width: 136.0,
      shape: BoxShape.rectangle,
      loadStateChanged: (ExtendedImageState value) {
        Widget child;
        if (value.extendedImageLoadState == LoadState.loading) {
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
        } else if (value.extendedImageLoadState == LoadState.failed) {
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
        } else {
          bangumiModel.coverSize = Size(
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
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: value.imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        return AspectRatio(
          aspectRatio: bangumiModel.coverSize == null
              ? 1
              : bangumiModel.coverSize!.width / bangumiModel.coverSize!.height,
          child: Hero(
            tag: this.heroTag,
            child: child,
          ),
        );
      },
    );
  }

  _showSubgroupPanel(
    final BuildContext context,
    final BangumiModel bangumiModel,
  ) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      topRadius: Radius.circular(16.0),
      builder: (context) {
        return BangumiSubgroupFragment(
          bangumiModel: bangumiModel,
        );
      },
    );
  }
}
