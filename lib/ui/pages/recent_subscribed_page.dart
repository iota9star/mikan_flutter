import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
@FFArgumentImport()
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/providers/recent_subscribed_model.dart';
import 'package:mikan_flutter/ui/components/rss_record_item.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@FFRoute(
  name: "recent-subscribed",
  routeName: "recent-subscribed",
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
        create: (_) => RecentSubscribedModel(this.loaded),
        child: Builder(builder: (context) {
          final RecentSubscribedModel recentSubscribedModel =
              Provider.of<RecentSubscribedModel>(context, listen: false);
          return Scaffold(
            body: NotificationListener(
              onNotification: (notification) {
                if (notification is OverscrollIndicatorNotification) {
                  notification.disallowGlow();
                } else if (notification is ScrollUpdateNotification) {
                  if (notification.depth == 0) {
                    final double offset = notification.metrics.pixels;
                    recentSubscribedModel.hasScrolled = offset > 0.0;
                  }
                }
                return true;
              },
              child: SmartRefresher(
                controller: recentSubscribedModel.refreshController,
                header: WaterDropMaterialHeader(
                  backgroundColor: theme.accentColor,
                  color: theme.accentColor.computeLuminance() < 0.5
                      ? Colors.white
                      : Colors.black,
                  distance: Sz.statusBarHeight + 42.0,
                ),
                footer: Indicator.footer(
                  context,
                  theme.accentColor,
                  bottom: 16.0 + Sz.navBarHeight,
                ),
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: recentSubscribedModel.refresh,
                onLoading: recentSubscribedModel.loadMoreRecentRecords,
                child: CustomScrollView(
                  slivers: [
                    _buildHeader(theme),
                    _buildRecordsList(theme),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecordsList(final ThemeData theme) {
    return SliverPadding(
      padding: EdgeInsets.only(
        bottom: 8.0,
        top: 8.0,
        left: 16.0,
        right: 16.0,
      ),
      sliver: Selector<RecentSubscribedModel, List<RecordItem>>(
        selector: (_, model) => model.records,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, records, __) {
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 360.0,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              mainAxisExtent: 176,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final RecordItem record = records[index];
                return RssRecordItem(
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
              childCount: records.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(final ThemeData theme) {
    return Selector<RecentSubscribedModel, bool>(
      selector: (_, model) => model.hasScrolled,
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, hasScrolled, __) {
        return SliverPinnedToBoxAdapter(
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: hasScrolled
                  ? theme.backgroundColor
                  : theme.scaffoldBackgroundColor,
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
              borderRadius: hasScrolled
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    )
                  : null,
            ),
            padding: EdgeInsets.only(
              top: 16.0 + Sz.statusBarHeight,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            duration: Duration(milliseconds: 240),
            child: Row(
              children: <Widget>[
                Text(
                  "订阅更新",
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
