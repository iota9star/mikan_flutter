import 'package:easy_refresh/easy_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'package:mikan/core/common/delegate.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/common/kit.dart';
import 'package:mikan/core/components/list_record_item.dart';
import 'package:mikan/core/components/simple_record_item.dart';
import 'package:mikan/features/settings/presentation/widgets/select_tablet_mode.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';
import 'package:mikan/core/widgets/transition_container.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/features/search/presentation/pages/search.dart';
import 'package:mikan/features/home/application/list_provider.dart';

/// 主页面组件
@immutable
class ListFragment extends ConsumerWidget {
  const ListFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(body: _ListScrollView());
  }
}

/// 滚动视图 - 处理刷新逻辑
class _ListScrollView extends ConsumerWidget {
  const _ListScrollView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EasyRefresh(
      header: defaultHeader,
      footer: defaultFooter(context),
      onRefresh: () async {
        final result = await ref.read(listProvider.notifier).refresh();
        if (result.hasUpdate) {
          '更新数据${result.updateCount}条'.toast();
        } else {
          '无内容更新'.toast();
        }
      },
      onLoad: () => ref.read(listProvider.notifier).loadMore(),
      child: const CustomScrollView(slivers: [_PinedHeader(), _ListSliver(), _BottomPadding()]),
    );
  }
}

/// Header - 不监听任何状态
class _PinedHeader extends StatelessWidget {
  const _PinedHeader();

  @override
  Widget build(BuildContext context) {
    return TabletModeBuilder(
      builder: (context, isTablet, child) {
        return SliverPinnedAppBar(
          title: '最新发布',
          autoImplLeading: false,
          actions: isTablet
              ? null
              : [
                  TransitionContainer(
                    next: const SearchPage(),
                    routeSettings: const RouteSettings(name: '/search'),
                    builder: (context, open) {
                      return IconButton(onPressed: open, icon: const Icon(Icons.search_rounded));
                    },
                  ),
                ],
        );
      },
    );
  }
}

/// 列表 Sliver - 只监听 records 数据
class _ListSliver extends ConsumerWidget {
  const _ListSliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(listProvider);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      sliver: listAsync.when(
        data: (listData) {
          final records = listData.records;
          if (records.isEmpty) {
            return emptySliverToBoxAdapter;
          }
          final margins = context.margins;
          return SliverWaterfallFlow(
            gridDelegate: SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              crossAxisSpacing: margins,
              mainAxisSpacing: margins,
              minCrossAxisExtent: 300.0,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final record = records[index];
              return ProviderScope(
                overrides: [currentRecordProvider.overrideWithValue(record)],
                child: const ListRecordItem(),
              );
            }, childCount: records.length),
          );
        },
        loading: () => const SliverToBoxAdapter(child: Center(child: ExpressiveLoadingIndicator())),
        error: (error, stack) => SliverToBoxAdapter(child: Center(child: Text('加载失败: $error'))),
      ),
    );
  }
}

/// 底部间距
class _BottomPadding extends StatelessWidget {
  const _BottomPadding();

  @override
  Widget build(BuildContext context) {
    return sliverGapH120WithNavBarHeight(context);
  }
}
