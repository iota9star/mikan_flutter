import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/providers/models/search_model.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class SearchFragment extends StatelessWidget {
  final ScrollController scrollController;

  const SearchFragment({Key key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color cationColor = Theme.of(context).textTheme.caption.color;
    final Color accentColor = Theme.of(context).accentColor;
    final TextStyle tagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    final Color scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;
    return Material(
      color: scaffoldBackgroundColor,
      child: ChangeNotifierProvider(
        create: (_) => SearchModel(),
        child: Builder(
          builder: (context) {
            return NotificationListener(
              onNotification: (notification) {
                if (notification is OverscrollIndicatorNotification) {
                  notification.disallowGlow();
                } else if (notification is ScrollUpdateNotification) {
                  if (notification.depth == 0) {
                    final double offset = notification.metrics.pixels;
                    context.read<SearchModel>().hasScrolled = offset > 0;
                  }
                }
                return false;
              },
              child: _buildCustomScrollView(
                context,
                cationColor,
                accentColor,
                tagStyle,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomScrollView(
    BuildContext context,
    Color cationColor,
    Color accentColor,
    TextStyle tagStyle,
  ) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        _buildHeader(context),
        _buildSubgroupSection(cationColor),
        _buildSubgroupList(context),
        _buildRecommendSection(cationColor),
        _buildRecommendList(),
        _buildSearchResultSection(cationColor),
        _buildSearchResultList(accentColor, tagStyle),
      ],
    );
  }

  Widget _buildSearchResultList(
    Color accentColor,
    TextStyle tagStyle,
  ) {
    return Selector<SearchModel, List<RecordItem>>(
      selector: (_, model) => model.searchResult?.searchs,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, records, __) {
        if (records.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, index) {
              final RecordItem record = records[index];
              return Selector<SearchModel, int>(
                selector: (_, model) => model.tapRecordItemIndex,
                shouldRebuild: (pre, next) => pre != next,
                builder: (context, tapRecordItemIndex, child) {
                  final Matrix4 transform = tapRecordItemIndex == index
                      ? Matrix4.diagonal3Values(0.9, 0.9, 1)
                      : Matrix4.identity();
                  return AnimatedTapContainer(
                    transform: transform,
                    child: child,
                    onTap: () {
                      // Navigator.pushNamed(
                      //   context,
                      //   Routes.mikanBangumiDetails,
                      //   arguments: {
                      //     "url": record.url,
                      //     "cover": record.cover,
                      //     "name": record.name,
                      //     "title": record.title,
                      //   },
                      // );
                    },
                    onTapStart: () {
                      context.read<SearchModel>().tapRecordItemIndex = index;
                    },
                    onTapEnd: () {
                      context.read<SearchModel>().tapRecordItemIndex = -1;
                    },
                  );
                },
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            record.title,
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            child: Wrap(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    right: 4.0,
                                    bottom: 4.0,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.87),
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                  child: Text(
                                    record.publishAt,
                                    style: tagStyle,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    right: 4.0,
                                    bottom: 4.0,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.87),
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                  child: Text(
                                    record.size,
                                    style: tagStyle,
                                  ),
                                ),
                                if (record.tags.isNotEmpty)
                                  ...List.generate(record.tags.length, (index) {
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
                                        color: accentColor.withOpacity(0.87),
                                        borderRadius:
                                            BorderRadius.circular(2.0),
                                      ),
                                      child: Text(
                                        record.tags[index],
                                        style: tagStyle,
                                      ),
                                    );
                                  })
                              ],
                            ),
                            padding: EdgeInsets.only(
                              top: 8.0,
                              bottom: 4.0,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(FluentIcons.channel_24_regular),
                                color: accentColor,
                                tooltip: "打开详情页",
                                iconSize: 20.0,
                                onPressed: () {},
                              ),
                              IconButton(
                                icon:
                                    Icon(FluentIcons.cloud_download_24_regular),
                                tooltip: "复制并尝试打开种子链接",
                                color: accentColor,
                                iconSize: 20.0,
                                onPressed: () {
                                  record.torrent.launchApp();
                                  record.torrent.copy();
                                },
                              ),
                              IconButton(
                                icon:
                                    Icon(FluentIcons.clipboard_link_24_regular),
                                color: accentColor,
                                tooltip: "复制并尝试打开磁力链接",
                                iconSize: 20.0,
                                onPressed: () {
                                  record.magnet.launchApp();
                                  record.magnet.copy();
                                },
                              ),
                              IconButton(
                                icon: Icon(FluentIcons.share_24_regular),
                                color: accentColor,
                                tooltip: "分享",
                                iconSize: 20.0,
                                onPressed: () {
                                  record.magnet.share();
                                },
                              ),
                              IconButton(
                                icon: Icon(FluentIcons.star_24_regular),
                                color: accentColor,
                                tooltip: "收藏",
                                iconSize: 20.0,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: records.length,
          ),
        );
      },
    );
  }

  Widget _buildSearchResultSection(Color cationColor) {
    return Selector<SearchModel, List<RecordItem>>(
      selector: (_, model) => model.searchResult?.searchs,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, records, child) {
        if (records.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        final double topPadding =
            Provider.of<SearchModel>(context, listen: false)
                        .searchResult
                        ?.bangumis
                        ?.isNullOrEmpty ==
                    true
                ? 16.0
                : 8.0;
        return SliverPinnedToBoxAdapter(
          child: Selector<SearchModel, bool>(
            selector: (_, model) => model.hasScrolled,
            shouldRebuild: (pre, next) => pre != next,
            builder: (_, hasScrolled, child) {
              return
                AnimatedContainer(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: topPadding,
                    bottom: 8.0,
                  ),
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .scaffoldBackgroundColor,
                      boxShadow: hasScrolled
                          ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.024),
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              spreadRadius: 3.0,
                            ),
                          ]
                        : null),
                duration: Duration(milliseconds: 240),
                child: child,
              );
            },
            child: Text(
              "搜索结果",
              style: TextStyle(
                fontSize: 14.0,
                height: 1.25,
                color: cationColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendList() {
    return Selector<SearchModel, List<Bangumi>>(
      selector: (_, model) => model.searchResult?.bangumis,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, bangumis, __) {
        if (bangumis.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        return SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            height: 196,
            child: WaterfallFlow.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: bangumis.length,
              itemBuilder: (_, index) {
                final bangumi = bangumis[index];
                final String currFlag =
                    "bangumi:${bangumi.id}:${bangumi.cover}";
                return Selector<SearchModel, String>(
                  builder: (context, tapScaleFlag, child) {
                    final Matrix4 transform = tapScaleFlag == currFlag
                        ? Matrix4.diagonal3Values(0.9, 0.9, 1)
                        : Matrix4.identity();
                    Widget cover =
                    _buildBangumiListItem(context, currFlag, bangumi);
                    return Tooltip(
                      message: bangumi.name,
                      child: AnimatedTapContainer(
                        height: double.infinity,
                        transform: transform,
                        margin: EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        onTapStart: () => context
                            .read<SearchModel>()
                            .tapBangumiItemFlag = currFlag,
                        onTapEnd: () => context
                            .read<SearchModel>()
                            .tapBangumiItemFlag = null,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8.0,
                              color: Colors.black.withAlpha(24),
                            )
                          ],
                        ),
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
                      ),
                    );
                  },
                  selector: (_, model) => model.tapBangumiItemFlag,
                  shouldRebuild: (pre, next) => pre != next,
                );
              },
              gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                lastChildLayoutTypeBuilder: (index) => LastChildLayoutType.none,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendSection(Color cationColor) {
    return Selector<SearchModel, List<Bangumi>>(
      selector: (_, model) => model.searchResult?.bangumis,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, bangumis, child) {
        if (bangumis.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        return SliverToBoxAdapter(child: child);
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 8.0,
        ),
        child: Text(
          "相关推荐",
          style: TextStyle(
            fontSize: 14.0,
            height: 1.25,
            color: cationColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSubgroupList(BuildContext context) {
    return Selector<SearchModel, List<Subgroup>>(
      selector: (_, model) => model.searchResult?.subgroups,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, subgroups, __) {
        if (subgroups.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        final bool less = subgroups.length < 5;
        return SliverPinnedToBoxAdapter(
          child: Container(
            width: double.infinity,
            height: less ? 56 : 96,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: WaterfallFlow.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 8.0,
                bottom: 8.0,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: subgroups.length,
              gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount: less ? 1 : 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                lastChildLayoutTypeBuilder: (index) => LastChildLayoutType.none,
              ),
              itemBuilder: (context, index) {
                final subgroup = subgroups[index];
                return Selector<SearchModel, String>(
                  builder: (_, subgroupId, __) {
                    final Color color = subgroup.id == subgroupId
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).accentColor;
                    return MaterialButton(
                      minWidth: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                        context.read<SearchModel>().subgroupId = subgroup.id;
                      },
                    );
                  },
                  selector: (_, model) => model.subgroupId,
                  shouldRebuild: (pre, next) => pre != next,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubgroupSection(Color cationColor) {
    return Selector<SearchModel, List<Subgroup>>(
      selector: (_, model) => model.searchResult?.subgroups,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, subgroups, child) {
        if (subgroups.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        return SliverToBoxAdapter(
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.only(
          top: 10.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Text(
          "字幕组",
          style: TextStyle(
            fontSize: 14.0,
            height: 1.25,
            color: cationColor,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverPinnedToBoxAdapter(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 24.0,
          bottom: 8.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Search",
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                ),
                Selector<SearchModel, bool>(
                  selector: (_, model) => model.loading,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (_, loading, __) {
                    if (loading) {
                      return CupertinoActivityIndicator(
                        radius: 12.0,
                      );
                    }
                    return Container();
                  },
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: "关闭",
                  icon: Icon(FluentIcons.dismiss_24_regular),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Builder(
              builder: (context) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelText: '请输入搜索关键字',
                      prefixIcon: Icon(
                        FluentIcons.search_24_regular,
                        color: Theme
                            .of(context)
                            .accentColor,
                      ),
                      contentPadding: EdgeInsets.only(top: -2),
                      alignLabelWithHint: true,
                    ),
                    cursorColor: Theme.of(context).accentColor,
                    textAlign: TextAlign.left,
                    autofocus: true,
                    maxLines: 1,
                    style: TextStyle(
                      height: 1.25,
                    ),
                    textInputAction: TextInputAction.search,
                    controller: Provider.of<SearchModel>(context, listen: false)
                        .keywordsController,
                    keyboardType: TextInputType.text,
                    onSubmitted: (keywords) {
                      if (keywords.isNullOrBlank) return;
                      context.read<SearchModel>().search(keywords);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBangumiListItem(
    final BuildContext context,
    final String currFlag,
    final Bangumi bangumi,
  ) {
    return ExtendedImage(
      image: CachedNetworkImageProvider(bangumi.cover),
      shape: BoxShape.rectangle,
      loadStateChanged: (ExtendedImageState value) {
        Widget child = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: 4,
              height: 12,
              margin: EdgeInsets.only(top: 2.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme
                        .of(context)
                        .accentColor,
                    Theme
                        .of(context)
                        .accentColor
                        .withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            SizedBox(width: 4.0),
            Expanded(
              child: Text(
                bangumi.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.0,
                  height: 1.25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
        Widget cover;
        if (value.extendedImageLoadState == LoadState.loading) {
          cover = Container(
            padding: EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: SpinKitPumpingHeart(
                duration: Duration(milliseconds: 960),
                itemBuilder: (_, __) =>
                    Image.asset(
                      "assets/mikan.png",
                    ),
              ),
            ),
          );
        }
        if (value.extendedImageLoadState == LoadState.failed) {
          cover = Container(
            decoration: BoxDecoration(
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
          cover = Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                image: value.imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        return AspectRatio(
          aspectRatio: bangumi.coverSize == null
              ? 3 / 4
              : bangumi.coverSize.width / bangumi.coverSize.height,
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: currFlag,
                  child: cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black45],
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
              Positioned(bottom: 8.0, right: 8.0, left: 8.0, child: child)
            ],
          ),
        );
      },
    );
  }
}
