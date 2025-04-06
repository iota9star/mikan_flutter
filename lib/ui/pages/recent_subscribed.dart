import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFAutoImport()
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../internal/delegate.dart';
import '../../internal/extension.dart';
import '../../internal/kit.dart';
@FFAutoImport()
import '../../model/record_item.dart';
import '../../providers/index_model.dart';
import '../../providers/recent_subscribed_model.dart';
import '../../topvars.dart';
import '../../widget/sliver_pinned_header.dart';
import '../components/rss_record_item.dart';

@FFRoute(name: '/subscribed/recent')
@immutable
class RecentSubscribedPage extends StatelessWidget {
  const RecentSubscribedPage({super.key, required this.loaded});

  final List<RecordItem> loaded;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => RecentSubscribedModel(loaded),
        child: Builder(
          builder: (context) {
            final model =
                Provider.of<RecentSubscribedModel>(context, listen: false);
            return Scaffold(
              body: EasyRefresh(
                header: defaultHeader,
                footer: defaultFooter(context),
                onRefresh: model.refresh,
                onLoad: model.loadMore,
                child: CustomScrollView(
                  slivers: [
                    SliverPinnedAppBar(
                      title: '最近更新',
                      actions: [
                        Selector<IndexModel, String?>(
                          selector: (_, model) => model.user?.rss,
                          builder: (context, rss, child) {
                            if (rss.isNullOrBlank) {
                              return const SizedBox.shrink();
                            }
                            return IconButton(
                              onPressed: () {
                                rss.copy();
                              },
                              icon: const Icon(Icons.rss_feed_rounded),
                            );
                          },
                        ),
                      ],
                    ),
                    _buildList(theme),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(ThemeData theme) {
    return SliverPadding(
      padding: edgeH24V8,
      sliver: Selector<RecentSubscribedModel, List<RecordItem>>(
        selector: (_, model) => model.records,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (context, records, __) {
          final margins = context.margins;
          return SliverWaterfallFlow(
            gridDelegate: SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 300.0,
              crossAxisSpacing: margins,
              mainAxisSpacing: margins,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final record = records[index];
                return RssRecordItem(
                  index: index,
                  record: record,
                );
              },
              childCount: records.length,
            ),
          );
        },
      ),
    );
  }
}
