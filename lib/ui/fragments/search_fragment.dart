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
import 'package:mikan_flutter/providers/search_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/components/simple_record_item.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@immutable
class SearchFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => SearchModel(),
      child: Builder(builder: (context) {
        final SearchModel searchModel =
            Provider.of<SearchModel>(context, listen: false);
        return Scaffold(
          body: NotificationListener(
            onNotification: (notification) {
              if (notification is OverscrollIndicatorNotification) {
                notification.disallowGlow();
              } else if (notification is ScrollUpdateNotification) {
                if (notification.depth == 0) {
                  final double offset = notification.metrics.pixels;
                  searchModel.hasScrolled = offset > 0.0;
                }
              }
              return true;
            },
            child: _buildCustomScrollView(context, theme, searchModel),
          ),
        );
      }),
    );
  }

  Widget _buildCustomScrollView(
    final BuildContext context,
    final ThemeData theme,
    final SearchModel searchModel,
  ) {
    return CustomScrollView(
      controller: ModalScrollController.of(context),
      slivers: [
        _buildHeader(context, theme, searchModel),
        _buildSubgroupSection(theme),
        _buildSubgroupList(theme, searchModel),
        _buildRecommendSection(theme),
        _buildRecommendList(theme),
        _buildSearchResultSection(theme),
        _buildSearchResultList(theme, searchModel),
      ],
    );
  }

  Widget _buildSearchResultList(
    final ThemeData theme,
    final SearchModel searchModel,
  ) {
    return Selector<SearchModel, List<RecordItem>?>(
      selector: (_, model) => model.searchResult?.records,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, records, __) {
        if (records.isNullOrEmpty) {
          return sliverToBoxAdapter;
        }
        return SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, index) {
                final RecordItem record = records![index];
                return SimpleRecordItem(
                  index: index,
                  record: record,
                  theme: theme,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.recordDetail.name,
                      arguments: Routes.recordDetail.d(url: record.url),
                    );
                  },
                );
              },
              childCount: records!.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResultSection(final ThemeData theme) {
    return Selector<SearchModel, List<RecordItem>?>(
      selector: (_, model) => model.searchResult?.records,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, records, child) {
        if (records.isNullOrEmpty) {
          return sliverToBoxAdapter;
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: edgeH16V8,
            child: Text(
              "搜索结果",
              style: TextStyle(
                fontSize: 14.0,
                height: 1.25,
                color: theme.textTheme.caption?.color,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendList(final ThemeData theme) {
    return Selector<SearchModel, List<Bangumi>?>(
      selector: (_, model) => model.searchResult?.bangumis,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, bangumis, __) {
        if (bangumis.isNullOrEmpty) {
          return sliverToBoxAdapter;
        }
        return SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            height: 220,
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: bangumis!.length,
              itemBuilder: (_, index) {
                final bangumi = bangumis[index];
                return _buildRecommendListItem(
                  context,
                  theme,
                  bangumi,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendListItem(
    final BuildContext context,
    final ThemeData theme,
    final Bangumi bangumi,
  ) {
    final String currFlag = "bangumi:${bangumi.id}:${bangumi.cover}";
    return Tooltip(
      message: bangumi.name,
      child: TapScaleContainer(
        height: double.infinity,
        margin: edgeHT16,
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
        child: AspectRatio(
          aspectRatio: 2.0 / 3.0,
          child: _buildBangumiListItem(
            theme,
            currFlag,
            bangumi,
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendSection(final ThemeData theme) {
    return Selector<SearchModel, List<Bangumi>?>(
      selector: (_, model) => model.searchResult?.bangumis,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, bangumis, child) {
        if (bangumis.isNullOrEmpty) {
          return sliverToBoxAdapter;
        }
        return SliverToBoxAdapter(child: child);
      },
      child: Padding(
        padding: edgeH16V8,
        child: Text(
          "相关推荐",
          style: TextStyle(
            fontSize: 14.0,
            height: 1.25,
            color: theme.textTheme.caption?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildSubgroupList(
    final ThemeData theme,
    final SearchModel searchModel,
  ) {
    return Selector<SearchModel, List<Subgroup>?>(
      selector: (_, model) => model.searchResult?.subgroups,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, subgroups, __) {
        if (subgroups.isNullOrEmpty) {
          return sliverToBoxAdapter;
        }
        final bool less = subgroups!.length < 5;
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
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: scrollHeaderBorderRadius(hasScrolled),
                    boxShadow: scrollHeaderBoxShadow(hasScrolled),
                  ),
                  duration: dur240,
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
                  return _buildSubgroupListItem(theme, subgroup, searchModel);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubgroupListItem(
    final ThemeData theme,
    final Subgroup subgroup,
    final SearchModel searchModel,
  ) {
    return Selector<SearchModel, String?>(
      selector: (_, model) => model.subgroupId,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, subgroupId, __) {
        final Color color =
            subgroup.id == subgroupId ? theme.primaryColor : theme.accentColor;
        return MaterialButton(
          minWidth: 0,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
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
            searchModel.subgroupId = subgroup.id;
          },
        );
      },
    );
  }

  Widget _buildSubgroupSection(final ThemeData theme) {
    return Selector<SearchModel, List<Subgroup>?>(
      selector: (_, model) => model.searchResult?.subgroups,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, subgroups, child) {
        if (subgroups.isNullOrEmpty) {
          return sliverToBoxAdapter;
        }
        return SliverToBoxAdapter(
          child: child,
        );
      },
      child: Padding(
        padding: edgeH16V8,
        child: Text(
          "字幕组",
          style: TextStyle(
            fontSize: 14.0,
            height: 1.25,
            color: theme.textTheme.caption?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    final BuildContext context,
    final ThemeData theme,
    final SearchModel searchModel,
  ) {
    return SliverPinnedToBoxAdapter(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 24.0,
          bottom: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderTitle(context),
            sizedBoxH12,
            _buildHeaderSearchField(theme, searchModel),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSearchField(
      final ThemeData theme, final SearchModel searchModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelText: '请输入搜索关键字',
          prefixIcon: Icon(
            FluentIcons.search_24_regular,
            color: theme.accentColor,
          ),
          contentPadding: EdgeInsets.only(top: -2),
          alignLabelWithHint: true,
        ),
        cursorColor: theme.accentColor,
        textAlign: TextAlign.left,
        autofocus: true,
        maxLines: 1,
        style: TextStyle(
          height: 1.25,
        ),
        textInputAction: TextInputAction.search,
        controller: searchModel.keywordsController,
        keyboardType: TextInputType.text,
        onSubmitted: (keywords) {
          if (keywords.isNullOrBlank) return;
          searchModel.search(keywords);
        },
      ),
    );
  }

  Widget _buildHeaderTitle(final BuildContext context) {
    return Row(
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
              return CupertinoActivityIndicator(radius: 12.0);
            }
            return sizedBox;
          },
        ),
        const SizedBox(width: 8.0),
        MaterialButton(
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minWidth: 0.0,
          child: Icon(FluentIcons.dismiss_24_regular),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildBangumiListItem(
    final ThemeData theme,
    final String currFlag,
    final Bangumi bangumi,
  ) {
    return ExtendedImage(
      image: ExtendedNetworkImageProvider(bangumi.cover),
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
                    theme.accentColor,
                    theme.accentColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            sizedBoxW4,
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
          cover = Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: ExtendedAssetImageProvider("assets/mikan.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
              ),
            ),
          );
        } else {
          bangumi.coverSize = Size(
            value.extendedImageInfo!.image.width.toDouble(),
            value.extendedImageInfo!.image.height.toDouble(),
          );
          cover = Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
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
              : bangumi.coverSize!.width / bangumi.coverSize!.height,
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
                      borderRadius: BorderRadius.circular(8.0)),
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
