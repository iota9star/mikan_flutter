import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
@FFArgumentImport()
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/providers/recent_subscribed_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/components/rss_record_item.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:mikan_flutter/widget/sliver_pinned_header.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@FFRoute(
  name: "recent-subscribed",
  routeName: "/subscribed/recent",
)
@immutable
class RecentSubscribedPage extends StatelessWidget {
  final List<RecordItem> loaded;

  const RecentSubscribedPage({Key? key, required this.loaded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => RecentSubscribedModel(loaded),
        child: Builder(builder: (context) {
          final model =
              Provider.of<RecentSubscribedModel>(context, listen: false);
          return Scaffold(
            body: SmartRefresher(
              controller: model.refreshController,
              header: WaterDropMaterialHeader(
                backgroundColor: theme.secondary,
                color: theme.secondary.isDark ? Colors.white : Colors.black,
                distance: Screens.statusBarHeight + 42.0,
              ),
              footer: Indicator.footer(
                context,
                theme.secondary,
                bottom: 16.0,
              ),
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: model.refresh,
              onLoading: model.loadMore,
              child: CustomScrollView(
                slivers: [
                  _buildHeader(),
                  _buildList(theme),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildList(final ThemeData theme) {
    return SliverPadding(
      padding: edgeH16V8,
      sliver: Selector<RecentSubscribedModel, List<RecordItem>>(
        selector: (_, model) => model.records,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, records, __) {
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 400.0,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              mainAxisExtent: 150.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final RecordItem record = records[index];
                return RssRecordItem(
                  index: index,
                  record: record,
                  theme: theme,
                  enableHero: false,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.recordDetail.name,
                      arguments: Routes.recordDetail.d(url: record.url),
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

  Widget _buildHeader() {
    return const SliverPinnedTitleHeader(title: "最近更新");
  }
}
