import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'package:mikan/res/assets.gen.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/core/common/app_utils.dart';
import 'package:mikan/core/common/consts.dart';
import 'package:mikan/core/common/delegate.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/common/image_provider.dart';
import 'package:mikan/core/models/bangumi.dart' as model;
import 'package:mikan/core/components/simple_record_item.dart';
import 'package:mikan/core/widgets/ripple_tap.dart';
import 'package:mikan/core/widgets/scalable_tap.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';
import 'package:mikan/core/widgets/transition_container.dart';
import 'package:mikan/features/bangumi/presentation/pages/bangumi.dart';
import 'package:mikan/features/search/application/search_provider.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          _SearchAppBar(),
          _SearchField(),
          _SearchHistory(),
          _SubgroupSection(),
          _SubgroupList(),
          _RecommendSection(),
          _RecommendList(),
          _SearchResultSection(),
          _SearchResultList(),
        ],
      ),
    );
  }
}

class _SearchAppBar extends ConsumerWidget {
  const _SearchAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(searchProvider);
    final isLoading = searchAsync.isLoading;

    return SliverPinnedAppBar(
      title: '搜索',
      actions: [
        if (isLoading)
          IconButton(
            icon: const ExpressiveLoadingIndicator(constraints: BoxConstraints.tightFor(width: 24, height: 24)),
            onPressed: () {},
          )
        else
          const SizedBox(),
      ],
    );
  }
}

class _SearchField extends HookConsumerWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final currentKeywords = ref.watch(searchKeywordsProvider);

    useEffect(() {
      final text = currentKeywords ?? '';
      if (controller.text == text) {
        return null;
      }

      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      return null;
    }, [controller, currentKeywords]);

    void submitKeywords(String keywords) {
      final trimmed = keywords.trim();
      if (trimmed.isEmpty) {
        '请输入搜索关键字'.toast();
        return;
      }

      ref.read(searchSubgroupIdProvider.notifier).clear();
      ref.read(searchKeywordsProvider.notifier).set(trimmed);
    }

    void clearKeywords() {
      controller.clear();
      ref.read(searchSubgroupIdProvider.notifier).clear();
      ref.read(searchKeywordsProvider.notifier).set(null);
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: TextField(
          decoration: InputDecoration(
            labelText: '请输入关键字',
            prefixIcon: const Icon(Icons.search_rounded, size: 24.0),
            isDense: true,
            border: const OutlineInputBorder(),
            suffixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, v, child) {
                  if (v.text.isNotEmpty) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: clearKeywords, icon: const Icon(Icons.clear_rounded, size: 24.0)),
                        IconButton(
                          icon: const Icon(Icons.rss_feed_rounded, size: 24.0),
                          onPressed: () {
                            '${MikanUrls.baseUrl}/RSS/Search?searchstr=${Uri.encodeComponent(controller.text)}'.copy();
                          },
                        ),
                      ],
                    );
                  }
                  return IconButton(
                    icon: const Icon(Icons.rss_feed_rounded, size: 24.0),
                    onPressed: () {
                      '${MikanUrls.baseUrl}/RSS/Search?searchstr=${Uri.encodeComponent(controller.text)}'.copy();
                    },
                  );
                },
              ),
            ),
            suffixIconConstraints: const BoxConstraints(),
          ),
          textInputAction: TextInputAction.search,
          controller: controller,
          keyboardType: TextInputType.text,
          onSubmitted: submitKeywords,
        ),
      ),
    );
  }
}

/// 搜索历史 - 不监听 searchProvider
class _SearchHistory extends ConsumerWidget {
  const _SearchHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: ValueListenableBuilder<Box>(
          valueListenable: Hive.box(HiveBoxKey.db).listenable(keys: [HiveDBKey.mikanSearch]),
          builder: (context, box, widget) {
            final keywords = box.get(HiveDBKey.mikanSearch, defaultValue: <String>[]);
            return keywords.isEmpty
                ? const SizedBox()
                : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...keywords.map((it) {
                        return RippleTap(
                          color: theme.primary.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                          onTap: () {
                            hideKeyboard();
                            ref.read(searchSubgroupIdProvider.notifier).clear();
                            ref.read(searchKeywordsProvider.notifier).set(it);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
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

/// 字幕组 Section - 只监听 subgroups
class _SubgroupSection extends ConsumerWidget {
  const _SubgroupSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subgroups = ref.watch(searchProvider.select((async) => async.dataOrNull?.subgroups));
    if (subgroups.isNullOrEmpty) {
      return emptySliverToBoxAdapter;
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Text('字幕组', style: theme.textTheme.titleMedium),
      ),
    );
  }
}

/// 字幕组列表 - 只监听 subgroups 和 subgroupId
class _SubgroupList extends ConsumerWidget {
  const _SubgroupList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subgroups = ref.watch(searchProvider.select((async) => async.dataOrNull?.subgroups));
    final subgroupId = ref.watch(searchSubgroupIdProvider);

    if (subgroups.isNullOrEmpty) {
      return emptySliverToBoxAdapter;
    }
    return SliverToBoxAdapter(
      child: Transform.translate(
        offset: offsetY_1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Wrap(
            runSpacing: 8.0,
            spacing: 8.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: List.generate(subgroups!.length, (index) {
              final subgroup = subgroups[index];
              final id = subgroup.id;
              if (id == null) {
                return const SizedBox();
              }
              final selected = id == subgroupId;
              return RippleTap(
                color: selected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                onTap: () {
                  ref.read(searchSubgroupIdProvider.notifier).toggle(id);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Text(
                    subgroup.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: selected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// 推荐 Section - 只监听 bangumis
class _RecommendSection extends ConsumerWidget {
  const _RecommendSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bangumis = ref.watch(searchProvider.select((async) => async.dataOrNull?.bangumis));
    if (bangumis.isNullOrEmpty) {
      return emptySliverToBoxAdapter;
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Text('相关推荐', style: theme.textTheme.titleMedium),
      ),
    );
  }
}

/// 推荐列表 - 只监听 bangumis
class _RecommendList extends ConsumerWidget {
  const _RecommendList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangumis = ref.watch(searchProvider.select((async) => async.dataOrNull?.bangumis));
    if (bangumis.isNullOrEmpty) {
      return emptySliverToBoxAdapter;
    }
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200.0,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          scrollDirection: Axis.horizontal,
          itemCount: bangumis!.length,
          itemBuilder: (context, index) {
            final bangumi = bangumis[index];
            return _RecommendListItem(bangumi: bangumi);
          },
        ),
      ),
    );
  }
}

/// 推荐列表项
class _RecommendListItem extends StatelessWidget {
  const _RecommendListItem({required this.bangumi});

  final model.Bangumi bangumi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String currFlag = 'bangumi:${bangumi.id}:${bangumi.cover}';
    return Tooltip(
      message: bangumi.name,
      child: Container(
        height: double.infinity,
        margin: const EdgeInsetsDirectional.only(end: 8.0),
        child: _buildBangumiListItem(context, theme, currFlag, bangumi),
      ),
    );
  }

  Widget _buildBangumiListItem(BuildContext context, ThemeData theme, String currFlag, model.Bangumi bangumi) {
    final provider = CacheImage(bangumi.cover);
    return AspectRatio(
      aspectRatio: 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TransitionContainer(
              routeSettings: const RouteSettings(name: '/bangumi'),
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
                                padding: const EdgeInsets.all(2.0),
                                child: Center(child: Assets.mikan.image()),
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
                              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.color),
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
                            image: DecorationImage(image: provider, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              next: BangumiPage(bangumiId: bangumi.id, cover: bangumi.cover, name: bangumi.name),
            ),
          ),
          const Gap(8),
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
}

/// 搜索结果 Section - 只监听 records
class _SearchResultSection extends ConsumerWidget {
  const _SearchResultSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final records = ref.watch(searchProvider.select((async) => async.dataOrNull?.records));
    if (records.isNullOrEmpty) {
      return emptySliverToBoxAdapter;
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Text('搜索结果', style: theme.textTheme.titleMedium),
      ),
    );
  }
}

/// 搜索结果列表 - 只监听 records
class _SearchResultList extends ConsumerWidget {
  const _SearchResultList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(searchProvider);

    return searchAsync.maybeWhen(
      ready: (searchResult) {
        final records = searchResult.records;
        if (records.isEmpty) {
          return emptySliverToBoxAdapter;
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          sliver: SliverWaterfallFlow(
            delegate: SliverChildBuilderDelegate((context, index) {
              final record = records[index];
              return ProviderScope(
                overrides: [currentRecordProvider.overrideWithValue(record)],
                child: const SimpleRecordItem(),
              );
            }, childCount: records.length),
            gridDelegate: const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
            ),
          ),
        );
      },
      failed: (failure) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text('搜索失败: ${failure.cause}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red)),
          ),
        ),
      ),
      orElse: () => emptySliverToBoxAdapter,
    );
  }
}
