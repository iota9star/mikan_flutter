import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../internal/consts.dart';
import '../../internal/delegate.dart';
import '../../internal/extension.dart';
import '../../internal/hive.dart';
import '../../internal/image_provider.dart';
import '../../internal/kit.dart';
import '../../internal/method.dart';
import '../../model/bangumi.dart';
import '../../model/record_item.dart';
import '../../model/subgroup.dart';
import '../../providers/search_model.dart';
import '../../res/assets.gen.dart';
import '../../topvars.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/scalable_tap.dart';
import '../../widget/sliver_pinned_header.dart';
import '../../widget/transition_container.dart';
import '../components/simple_record_item.dart';
import 'bangumi.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => SearchModel(),
        child: Builder(
          builder: (context) {
            final searchModel =
                Provider.of<SearchModel>(context, listen: false);
            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverPinnedAppBar(
                    title: '搜索',
                    actions: [
                      Selector<SearchModel, bool>(
                        selector: (_, model) => model.loading,
                        shouldRebuild: (pre, next) => pre != next,
                        builder: (_, loading, __) {
                          if (loading) {
                            return IconButton(
                              icon: const SizedBox(
                                width: 24.0,
                                height: 24.0,
                                child: CircularProgressIndicator(),
                              ),
                              onPressed: () {},
                            );
                          }
                          return sizedBox;
                        },
                      ),
                    ],
                  ),
                  _buildHeaderSearchField(theme, searchModel),
                  _buildSearchHistory(theme, searchModel),
                  _buildSubgroupSection(theme),
                  _buildSubgroupList(theme, searchModel),
                  _buildRecommendSection(theme),
                  _buildRecommendList(theme),
                  _buildSearchResultSection(theme),
                  _buildSearchResultList(theme, searchModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResultList(
    ThemeData theme,
    SearchModel searchModel,
  ) {
    return SliverPadding(
      padding: edgeH24B16,
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
                final record = records[index];
                return SimpleRecordItem(record: record);
              },
              childCount: records!.length,
            ),
            gridDelegate: SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              mainAxisSpacing: context.margins,
              crossAxisSpacing: context.margins,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResultSection(ThemeData theme) {
    return Selector<SearchModel, List<RecordItem>?>(
      selector: (_, model) => model.searchResult?.records,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, records, child) {
        if (records.isNullOrEmpty) {
          return emptySliverToBoxAdapter;
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: edgeH24V8,
            child: Text(
              '搜索结果',
              style: theme.textTheme.titleMedium,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendList(ThemeData theme) {
    return Selector<SearchModel, List<Bangumi>?>(
      selector: (_, model) => model.searchResult?.bangumis,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (context, bangumis, __) {
        if (bangumis.isNullOrEmpty) {
          return emptySliverToBoxAdapter;
        }
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 200.0,
            child: ListView.builder(
              padding: edgeH24B16,
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
    BuildContext context,
    ThemeData theme,
    Bangumi bangumi,
  ) {
    final String currFlag = 'bangumi:${bangumi.id}:${bangumi.cover}';
    return Tooltip(
      message: bangumi.name,
      child: Container(
        height: double.infinity,
        margin: EdgeInsetsDirectional.only(end: context.margins),
        child: _buildBangumiListItem(
          context,
          theme,
          currFlag,
          bangumi,
        ),
      ),
    );
  }

  Widget _buildRecommendSection(ThemeData theme) {
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
        padding: edgeH24V8,
        child: Text(
          '相关推荐',
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }

  Widget _buildSubgroupList(
    ThemeData theme,
    SearchModel searchModel,
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
            child: Padding(
              padding: edgeH24B16,
              child: Wrap(
                runSpacing: 8.0,
                spacing: 8.0,
                crossAxisAlignment: WrapCrossAlignment.center,
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
    ThemeData theme,
    Subgroup subgroup,
    SearchModel searchModel,
  ) {
    return Selector<SearchModel, String?>(
      selector: (_, model) => model.subgroupId,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, subgroupId, __) {
        final selected = subgroup.id == subgroupId;
        return RippleTap(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: borderRadius8,
          onTap: () {
            searchModel.subgroupId = subgroup.id;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Text(
              subgroup.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge!.copyWith(
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubgroupSection(ThemeData theme) {
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
        padding: edgeH24V8,
        child: Text(
          '字幕组',
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }

  Widget _buildHeaderSearchField(
    ThemeData theme,
    SearchModel searchModel,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: edgeH24V8,
        child: TextField(
          decoration: InputDecoration(
            labelText: '请输入关键字',
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 24.0,
            ),
            isDense: true,
            border: const OutlineInputBorder(),
            suffixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: ValueListenableBuilder(
                valueListenable: searchModel.keywordsController,
                builder: (context, v, child) {
                  if (v.text.isNotEmpty) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            searchModel.keywordsController.clear();
                          },
                          icon: const Icon(
                            Icons.clear_rounded,
                            size: 24.0,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.rss_feed_rounded,
                            size: 24.0,
                          ),
                          onPressed: () {
                            '${MikanUrls.baseUrl}/RSS/Search?searcher=${Uri.encodeComponent(searchModel.keywordsController.text)}'
                                .copy();
                          },
                        ),
                      ],
                    );
                  }
                  return IconButton(
                    icon: const Icon(
                      Icons.rss_feed_rounded,
                      size: 24.0,
                    ),
                    onPressed: () {
                      '${MikanUrls.baseUrl}/RSS/Search?searcher=${Uri.encodeComponent(searchModel.keywordsController.text)}'
                          .copy();
                    },
                  );
                },
              ),
            ),
            suffixIconConstraints: const BoxConstraints(),
          ),
          autofocus: true,
          textInputAction: TextInputAction.search,
          controller: searchModel.keywordsController,
          keyboardType: TextInputType.text,
          onSubmitted: (keywords) {
            if (keywords.isNullOrBlank) {
              return;
            }
            searchModel.search(keywords);
          },
        ),
      ),
    );
  }

  Widget _buildBangumiListItem(
    BuildContext context,
    ThemeData theme,
    String currFlag,
    Bangumi bangumi,
  ) {
    final provider = CacheImage(bangumi.cover);
    return AspectRatio(
      aspectRatio: 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TransitionContainer(
              builder: (context, open) {
                return ScalableCard(
                  onTap: open,
                  child: Image(
                    image: provider,
                    loadingBuilder: (_, child, event) {
                      return event == null
                          ? child
                          : Hero(
                              tag: currFlag,
                              child: Container(
                                padding: edge28,
                                child: Center(
                                  child: Assets.mikan.image(),
                                ),
                              ),
                            );
                    },
                    errorBuilder: (_, __, ___) {
                      return Hero(
                        tag: currFlag,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: Assets.mikan.provider(),
                              fit: BoxFit.cover,
                              colorFilter: const ColorFilter.mode(
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
                            image: DecorationImage(
                              image: provider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              next: BangumiPage(
                bangumiId: bangumi.id,
                cover: bangumi.cover,
                name: bangumi.name,
              ),
            ),
          ),
          sizedBoxH8,
          Text(
            '${bangumi.name}\n',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(ThemeData theme, SearchModel searchModel) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: edgeH24B16,
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
                        return RippleTap(
                          color: theme.primary.withOpacity(0.1),
                          borderRadius: borderRadius8,
                          onTap: () {
                            hideKeyboard();
                            searchModel.search(it);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            child: Text(
                              it,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge,
                            ),
                          ),
                        );
                      }).toList(),
                      IconButton(
                        onPressed: () {
                          MyHive.db.delete(HiveDBKey.mikanSearch);
                        },
                        icon: const Icon(Icons.clear_all_rounded),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
