import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/providers/search_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/components/simple_record_item.dart';
import 'package:mikan_flutter/widget/sliver_pinned_header.dart';
import 'package:mikan_flutter/widget/tap_scale_container.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@immutable
class SearchFragment extends StatelessWidget {
  const SearchFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => SearchModel(),
      child: Builder(builder: (context) {
        final searchModel = Provider.of<SearchModel>(context, listen: false);
        return Scaffold(
          body: _buildCustomScrollView(context, theme, searchModel),
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
        _buildHeader(theme, searchModel),
        _buildSearchHistory(theme, searchModel),
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
    return SliverPadding(
      padding: edgeH16B16,
      sliver: Selector<SearchModel, List<RecordItem>?>(
        selector: (_, model) => model.searchResult?.records,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (context, records, __) {
          if (records.isNullOrEmpty) {
            return emptySliverToBoxAdapter;
          }
          return SliverWaterfallFlow(
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
            gridDelegate:
                const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResultSection(final ThemeData theme) {
    return Selector<SearchModel, List<RecordItem>?>(
      selector: (_, model) => model.searchResult?.records,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, records, child) {
        if (records.isNullOrEmpty) {
          return emptySliverToBoxAdapter;
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: edgeH16V12,
            child: Text(
              "搜索结果",
              style: TextStyle(
                fontSize: 15.0,
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
          return emptySliverToBoxAdapter;
        }
        return SliverToBoxAdapter(
          child: Container(
            color: theme.backgroundColor,
            height: 220,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: edge16,
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
        margin: const EdgeInsetsDirectional.only(end: 12.0),
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
        child: _buildBangumiListItem(
          theme,
          currFlag,
          bangumi,
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
          return emptySliverToBoxAdapter;
        }
        return SliverToBoxAdapter(child: child);
      },
      child: Padding(
        padding: edgeH16V12,
        child: Text(
          "相关推荐",
          style: TextStyle(
            fontSize: 15.0,
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
          return emptySliverToBoxAdapter;
        }
        return SliverToBoxAdapter(
          child: Transform.translate(
            offset: offsetY_1,
            child: Container(
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
              padding: edgeH16,
              child: Wrap(
                runSpacing: 8.0,
                spacing: 8.0,
                children: List.generate(
                  subgroups!.length,
                  (index) {
                    final subgroup = subgroups[index];
                    return _buildSubgroupListItem(
                      theme,
                      subgroup,
                      searchModel,
                    );
                  },
                ),
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
            subgroup.id == subgroupId ? theme.primary : theme.secondary;
        return MaterialButton(
          minWidth: 0,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius10),
          color: color.withOpacity(0.12),
          elevation: 0,
          onPressed: () {
            searchModel.subgroupId = subgroup.id;
          },
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            subgroup.name,
            style: TextStyle(
              fontSize: 14.0,
              color: color,
            ),
          ),
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
          return emptySliverToBoxAdapter;
        }
        return SliverToBoxAdapter(child: child);
      },
      child: Padding(
        padding: edgeH16V12,
        child: Text(
          "字幕组",
          style: TextStyle(
            fontSize: 15.0,
            height: 1.25,
            color: theme.textTheme.caption?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    final ThemeData theme,
    final SearchModel searchModel,
  ) {
    final it = ColorTween(
      begin: theme.backgroundColor,
      end: theme.scaffoldBackgroundColor,
    );
    return StackSliverPinnedHeader(
      maxExtent: 200.0,
      minExtent: 120.0,
      childrenBuilder: (context, ratio) {
        final ic = it.transform(ratio);
        return [
          Positioned(
            left: 0,
            top: 12.0,
            child: MaterialButton(
              minWidth: 32.0,
              color: ic,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: circleShape,
              padding: EdgeInsets.zero,
              child: const Icon(
                FluentIcons.chevron_left_24_regular,
                size: 16.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 78 * (1 - ratio) + 16,
            left: ratio * 44,
            child: Text(
              "搜索",
              style: TextStyle(
                fontSize: 30.0 - (ratio * 6.0),
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildHeaderSearchField(theme, searchModel),
          ),
        ];
      },
    );
  }

  Widget _buildHeaderSearchField(
    final ThemeData theme,
    final SearchModel searchModel,
  ) {
    return TextField(
      decoration: InputDecoration(
        labelText: '请输入关键字',
        prefixIcon: Icon(
          FluentIcons.search_24_regular,
          color: theme.secondary,
        ),
        contentPadding: const EdgeInsets.only(
          left: 14.0,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: Selector<SearchModel, bool>(
            selector: (_, model) => model.loading,
            shouldRebuild: (pre, next) => pre != next,
            builder: (_, loading, __) {
              if (loading) {
                return CircularProgressIndicator(
                  color: theme.secondary,
                  strokeWidth: 2.0,
                );
              }
              return sizedBox;
            },
          ),
        ),
        suffixIconConstraints: const BoxConstraints(
          maxWidth: 30.0,
          maxHeight: 16.0,
        ),
      ),
      cursorColor: theme.secondary,
      textAlign: TextAlign.left,
      autofocus: true,
      maxLines: 1,
      style: textStyle14,
      textInputAction: TextInputAction.search,
      controller: searchModel.keywordsController,
      keyboardType: TextInputType.text,
      onSubmitted: (keywords) {
        if (keywords.isNullOrBlank) return;
        searchModel.search(keywords);
      },
    );
  }

  Widget _buildBangumiListItem(
    final ThemeData theme,
    final String currFlag,
    final Bangumi bangumi,
  ) {
    final boxShadow = [
      BoxShadow(
        blurRadius: 8.0,
        color: Colors.black.withAlpha(24),
      ),
    ];
    final provider = CacheImageProvider(bangumi.cover);
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Column(
        children: [
          Expanded(
            child: Image(
              image: provider,
              loadingBuilder: (_, child, event) {
                return event == null
                    ? child
                    : Hero(
                        tag: currFlag,
                        child: Container(
                          padding: edge28,
                          decoration: BoxDecoration(
                            borderRadius: borderRadius8,
                            boxShadow: boxShadow,
                          ),
                          child: Center(
                            child: SpinKitPumpingHeart(
                              duration: const Duration(milliseconds: 960),
                              itemBuilder: (_, __) => Image.asset(
                                "assets/mikan.png",
                              ),
                            ),
                          ),
                        ),
                      );
              },
              errorBuilder: (_, __, ___) {
                return Hero(
                  tag: currFlag,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius8,
                      boxShadow: boxShadow,
                      image: const DecorationImage(
                        image: AssetImage("assets/mikan.png"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.grey,
                          BlendMode.color,
                        ),
                      ),
                    ),
                  ),
                );
              },
              frameBuilder: (_, __, ___, ____) {
                return Hero(
                  tag: currFlag,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius8,
                      boxShadow: boxShadow,
                      image: DecorationImage(
                        image: provider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          sizedBoxH8,
          Text(
            '${bangumi.name}\n',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(ThemeData theme, SearchModel searchModel) {
    final bgc = theme.primary.withOpacity(0.18);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ValueListenableBuilder<Box>(
          valueListenable:
              Hive.box(HiveBoxKey.db).listenable(keys: [HiveDBKey.mikanSearch]),
          builder: (context, box, widget) {
            final keywords =
                box.get(HiveDBKey.mikanSearch, defaultValue: <String>[]);
            return keywords.isEmpty
                ? sizedBox
                : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...keywords.map((it) {
                        return ActionChip(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          tooltip: it,
                          label: Text(
                            it,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: theme.primary,
                            ),
                          ),
                          backgroundColor: bgc,
                          onPressed: () {
                            searchModel.search(it);
                          },
                        );
                      }).toList(),
                      SizedBox(
                        width: 28.0,
                        height: 28.0,
                        child: MaterialButton(
                          onPressed: () {
                            MyHive.db.delete(HiveDBKey.mikanSearch);
                          },
                          minWidth: 28.0,
                          height: 28.0,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          shape: circleShape,
                          child: const Icon(
                            FluentIcons.delete_24_regular,
                            size: 14.0,
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
