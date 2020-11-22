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
import 'package:mikan_flutter/ui/components/simple_record_item.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@immutable
class SearchFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;
    return Material(
      color: scaffoldBackgroundColor,
      child: ChangeNotifierProvider(
        create: (_) => SearchModel(),
        child: Builder(builder: (context) {
          return NotificationListener(
            onNotification: (notification) {
              if (notification is OverscrollIndicatorNotification) {
                notification.disallowGlow();
              } else if (notification is ScrollUpdateNotification) {
                if (notification.depth == 0) {
                  final double offset = notification.metrics.pixels;
                  context.read<SearchModel>().hasScrolled = offset > 0.0;
                }
              }
              return true;
            },
            child: _buildCustomScrollView(context, scaffoldBackgroundColor),
          );
        }),
      ),
    );
  }

  Widget _buildCustomScrollView(
    final BuildContext context,
    final Color scaffoldBackgroundColor,
  ) {
    final Color cationColor = Theme.of(context).textTheme.caption.color;
    return CustomScrollView(
      controller: ModalScrollController.of(context),
      slivers: [
        _buildHeader(context, scaffoldBackgroundColor),
        _buildSubgroupSection(cationColor),
        _buildSubgroupList(context, scaffoldBackgroundColor),
        _buildRecommendSection(cationColor),
        _buildRecommendList(),
        _buildSearchResultSection(cationColor),
        _buildSearchResultList(context),
      ],
    );
  }

  Widget _buildSearchResultList(final BuildContext context) {
    final Color accentColor = Theme.of(context).accentColor;
    final Color primaryColor = Theme.of(context).primaryColor;
    final TextStyle fileTagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color: accentColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    final TextStyle titleTagStyle = TextStyle(
      fontSize: 10,
      height: 1.25,
      color:
          primaryColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    final Color backgroundColor = Theme.of(context).backgroundColor;
    return Selector<SearchModel, List<RecordItem>>(
      selector: (_, model) => model.searchResult?.records,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, records, __) {
        if (records.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        return SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          sliver: SliverList(
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
                    return SimpleRecordItem(
                      index: index,
                      record: record,
                      accentColor: accentColor,
                      primaryColor: primaryColor,
                      backgroundColor: backgroundColor,
                      fileTagStyle: fileTagStyle,
                      titleTagStyle: titleTagStyle,
                      transform: transform,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.recordDetail.name,
                          arguments: Routes.recordDetail.d(url: record.url),
                        );
                      },
                      onTapStart: () {
                        context.read<SearchModel>().tapRecordItemIndex = index;
                      },
                      onTapEnd: () {
                        context.read<SearchModel>().tapRecordItemIndex = -1;
                      },
                    );
                  },
                );
              },
              childCount: records.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResultSection(final Color cationColor) {
    return Selector<SearchModel, List<RecordItem>>(
      selector: (_, model) => model.searchResult?.records,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, records, child) {
        if (records.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              top: 8.0,
              left: 16.0,
              right: 16.0,
              bottom: 8.0,
            ),
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
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, bangumis, __) {
        if (bangumis.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        return SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            height: 220,
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
                  selector: (_, model) => model.tapBangumiItemFlag,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (context, tapScaleFlag, child) {
                    final Matrix4 transform = tapScaleFlag == currFlag
                        ? Matrix4.diagonal3Values(0.9, 0.9, 1)
                        : Matrix4.identity();
                    Widget cover = _buildBangumiListItem(
                      context,
                      currFlag,
                      bangumi,
                    );
                    return Tooltip(
                      message: bangumi.name,
                      child: AnimatedTapContainer(
                        height: double.infinity,
                        transform: transform,
                        margin: EdgeInsets.symmetric(
                          vertical: 16.0,
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
                            Routes.bangumi.name,
                            arguments: Routes.bangumi.d(
                              heroTag: currFlag,
                              bangumiId: bangumi.id,
                              cover: bangumi.cover,
                            ),
                          );
                        },
                        child: cover,
                      ),
                    );
                  },
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

  Widget _buildRecommendSection(final Color cationColor) {
    return Selector<SearchModel, List<Bangumi>>(
      selector: (_, model) => model.searchResult?.bangumis,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, bangumis, child) {
        if (bangumis.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        return SliverToBoxAdapter(child: child);
      },
      child: Padding(
        padding: EdgeInsets.only(
          top: 8.0,
          left: 16.0,
          right: 16.0,
          bottom: 8.0,
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

  Widget _buildSubgroupList(
    final BuildContext context,
    final Color scaffoldBackgroundColor,
  ) {
    return Selector<SearchModel, List<Subgroup>>(
      selector: (_, model) => model.searchResult?.subgroups,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, subgroups, __) {
        if (subgroups.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        final bool less = subgroups.length < 5;
        return SliverPinnedToBoxAdapter(
          child: Transform.translate(
            offset: Offset(0, -2),
            child: Selector<SearchModel, bool>(
              selector: (_, model) => model.hasScrolled,
              shouldRebuild: (pre, next) => pre != next,
              builder: (_, hasScrolled, child) {
                return AnimatedContainer(
                  width: double.infinity,
                  height: less ? 72.0 : 112.0,
                  decoration: BoxDecoration(
                    color: scaffoldBackgroundColor,
                    boxShadow: hasScrolled
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.024),
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              spreadRadius: 3.0,
                            ),
                          ]
                        : null,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                  ),
                  duration: Duration(milliseconds: 240),
                  child: child,
                );
              },
              child: WaterfallFlow.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: subgroups.length,
                gridDelegate:
                    SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                  crossAxisCount: less ? 1 : 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  lastChildLayoutTypeBuilder: (index) =>
                      LastChildLayoutType.none,
                ),
                itemBuilder: (context, index) {
                  final subgroup = subgroups[index];
                  return Selector<SearchModel, String>(
                    selector: (_, model) => model.subgroupId,
                    shouldRebuild: (pre, next) => pre != next,
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
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubgroupSection(final Color cationColor) {
    return Selector<SearchModel, List<Subgroup>>(
      selector: (_, model) => model.searchResult?.subgroups,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, subgroups, child) {
        if (subgroups.isNullOrEmpty) {
          return SliverToBoxAdapter();
        }
        return SliverToBoxAdapter(
          child: child,
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
          top: 8.0,
          left: 16.0,
          right: 16.0,
          bottom: 8.0,
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

  Widget _buildHeader(
    final BuildContext context,
    final Color scaffoldBackgroundColor,
  ) {
    return SliverPinnedToBoxAdapter(
      child: Container(
        color: scaffoldBackgroundColor,
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 24.0,
          bottom: 16.0,
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
                      fontSize: 24.0,
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
                        color: Theme.of(context).accentColor,
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
    return ExtendedImage.network(
      bangumi.cover,
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
                    Theme.of(context).accentColor,
                    Theme.of(context).accentColor.withOpacity(0.1),
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
                itemBuilder: (_, __) => ExtendedImage.asset(
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
