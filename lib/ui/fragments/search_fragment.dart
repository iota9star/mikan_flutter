import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/providers/models/SearchModel.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class SearchFragment extends StatelessWidget {
  final ScrollController scrollController;

  const SearchFragment({Key key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ChangeNotifierProvider(
        create: (_) => SearchModel(),
        child: Container(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 24.0,
          ),
          child: CustomScrollView(
            // controller: scrollController,
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverPinnedToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Search",
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    )
                  ],
                ),
              ),
              Selector<SearchModel, List<Subgroup>>(
                selector: (_, model) => model.search?.subgroups,
                shouldRebuild: (pre, next) => pre != next,
                builder: (_, subgroups, __) {
                  if (subgroups.isNullOrEmpty) {
                    return SliverToBoxAdapter();
                  }
                  return SliverPinnedToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      height: 96,
                      child: WaterfallFlow.builder(
                        itemBuilder: (context, index) {
                          final subgroup = subgroups[index];
                          return Selector<SearchModel, String>(
                            builder: (_, subgroupId, __) {
                              final Color color = subgroup.id == subgroupId
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).accentColor;
                              return MaterialButton(
                                minWidth: 0,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                child: Text(
                                  subgroup.name,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    height: 1.25,
                                    fontWeight: FontWeight.w500,
                                    color: color,
                                  ),
                                ),
                                color: color.withOpacity(0.12),
                                elevation: 0,
                                onPressed: () {
                                  context.read<SearchModel>().subgroupId =
                                      subgroup.id;
                                },
                              );
                            },
                            selector: (_, model) => model.subgroupId,
                            shouldRebuild: (pre, next) => pre != next,
                          );
                        },
                        scrollDirection: Axis.horizontal,
                        itemCount: subgroups.length,
                        gridDelegate:
                            SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          lastChildLayoutTypeBuilder: (index) =>
                              LastChildLayoutType.none,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Selector<SearchModel, List<Bangumi>>(
                selector: (_, model) => model.search?.bangumis,
                shouldRebuild: (pre, next) => pre != next,
                builder: (_, bangumis, __) {
                  if (bangumis.isNullOrEmpty) {
                    return SliverToBoxAdapter();
                  }
                  return SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      child: WaterfallFlow.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: bangumis.length,
                        itemBuilder: (_, index) {
                          final bangumi = bangumis[index];
                          final String currFlag =
                              "bangumi:${bangumi.id}:${bangumi.cover}";
                          return Selector<SearchModel, String>(
                            builder: (context, tapScaleFlag, child) {
                              Matrix4 transform;
                              if (tapScaleFlag == currFlag) {
                                transform =
                                    Matrix4.diagonal3Values(0.9, 0.9, 1);
                              } else {
                                transform = Matrix4.identity();
                              }
                              Widget cover =
                                  _buildBangumiListItem(currFlag, bangumi);
                              return AnimatedTapContainer(
                                height: 200,
                                transform: transform,
                                onTapStart: () => context
                                    .read<SearchModel>()
                                    .tapBangumiItemFlag = currFlag,
                                onTapEnd: () => context
                                    .read<SearchModel>()
                                    .tapBangumiItemFlag = null,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.bangumiDetails,
                                    arguments: {
                                      "heroTag": currFlag,
                                      "bangumiId": bangumi.id,
                                      "cover": bangumi.cover,
                                    },
                                  );
                                },
                                child: cover,
                              );
                            },
                            selector: (_, model) => model.tapBangumiItemFlag,
                            shouldRebuild: (pre, next) => pre != next,
                          );
                        },
                        gridDelegate:
                            SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          lastChildLayoutTypeBuilder: (index) =>
                              LastChildLayoutType.none,
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBangumiListItem(final String currFlag, final Bangumi bangumi) {
    Widget widget = ExtendedImage(
      image: CachedNetworkImageProvider(bangumi.cover),
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
                  color: Colors.black.withAlpha(24),
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: SpinKitPumpingHeart(
                duration: Duration(milliseconds: 960),
                itemBuilder: (_, __) => Image.asset(
                  "assets/mikan.png",
                ),
              ),
            ),
          );
        }
        if (value.extendedImageLoadState == LoadState.failed) {
          child = Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withAlpha(24),
                )
              ],
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                image: ExtendedAssetImageProvider("assets/mikan.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
              ),
            ),
          );
        } else if (value.extendedImageLoadState == LoadState.completed) {
          bangumi.coverSize = Size(
            value.extendedImageInfo.image.width.toDouble(),
            value.extendedImageInfo.image.height.toDouble(),
          );
          child = Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: Colors.black.withAlpha(24),
                )
              ],
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          );
        }
        return AspectRatio(
          aspectRatio: bangumi.coverSize == null
              ? 1
              : bangumi.coverSize.width / bangumi.coverSize.height,
          child: Hero(
            tag: currFlag,
            child: child,
          ),
        );
      },
    );
    return widget;
  }
}
