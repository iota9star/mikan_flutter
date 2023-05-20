import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/delegate.dart';
import '../../internal/extension.dart';
import '../../mikan_routes.dart';
@FFArgumentImport()
import '../../model/record_item.dart';
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
                    const SliverPinnedAppBar(title: '最近更新'),
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
        builder: (_, records, __) {
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              mainAxisExtent: 164.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final RecordItem record = records[index];
                return RssRecordItem(
                  index: index,
                  record: record,
                  enableHero: false,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.record.name,
                      arguments: Routes.record.d(url: record.url),
                    );
                  },
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
