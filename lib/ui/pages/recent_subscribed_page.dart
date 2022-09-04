import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
  routeName: "/recent-subscribed",
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
                distance: Screen.statusBarHeight + 42.0,
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
                  _buildHeader(theme),
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
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              mainAxisExtent: 178.0,
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

  Widget _buildHeader(final ThemeData theme) {
    final it = ColorTween(
      begin: theme.backgroundColor,
      end: theme.scaffoldBackgroundColor,
    );
    return SimpleSliverPinnedHeader(
      builder: (context, ratio) {
        final ic = it.transform(ratio);
        return Row(
          children: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: ic,
              minWidth: 32.0,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: circleShape,
              child: const Icon(
                FluentIcons.chevron_left_24_regular,
                size: 16.0,
              ),
            ),
            sizedBoxW12,
            Text(
              "最近更新",
              style: TextStyle(
                fontSize: 30.0 - (ratio * 6.0),
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),
          ],
        );
      },
    );
  }
}
