import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/providers/list_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/components/normal_record_item.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@immutable
class ListFragment extends StatelessWidget {
  const ListFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final model = Provider.of<ListModel>(context, listen: false);
    return Scaffold(
      body: NotificationListener(
        onNotification: (notification) {
          if (notification is OverscrollIndicatorNotification) {
            notification.disallowGlow();
          } else if (notification is ScrollUpdateNotification) {
            if (notification.depth == 0) {
              final double offset = notification.metrics.pixels;
              model.hasScrolled = offset > 0.0;
            }
          }
          return true;
        },
        child: SmartRefresher(
          header: WaterDropMaterialHeader(
            backgroundColor: theme.secondary,
            color: theme.secondary.isDark ? Colors.white : Colors.black,
            distance: Screen.statusBarHeight + 42.0,
          ),
          footer: Indicator.footer(
            context,
            theme.secondary,
            bottom: 80.0,
          ),
          enablePullDown: true,
          enablePullUp: true,
          controller: model.refreshController,
          onRefresh: model.refresh,
          onLoading: model.loadMore,
          child: CustomScrollView(
            slivers: [
              _buildHeader(theme),
              _buildList(theme, model),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(final ThemeData theme, final ListModel listModel) {
    return SliverPadding(
      padding: edgeH16V8,
      sliver: Selector<ListModel, int>(
        selector: (_, model) => model.changeFlag,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, __, ___) {
          final List<RecordItem> records = listModel.records;
          if (records.isEmpty) {
            return emptySliverToBoxAdapter;
          }
          return SliverWaterfallFlow(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final RecordItem record = records[index];
                return NormalRecordItem(
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
            gridDelegate:
                const SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              minCrossAxisExtent: 360,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(final ThemeData theme) {
    return SliverPinnedToBoxAdapter(
      child: Selector<ListModel, bool>(
        selector: (_, model) => model.hasScrolled,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, hasScrolled, __) {
          return AnimatedContainer(
            decoration: BoxDecoration(
              color: hasScrolled
                  ? theme.backgroundColor
                  : theme.scaffoldBackgroundColor,
              borderRadius: scrollHeaderBorderRadius(hasScrolled),
              boxShadow: scrollHeaderBoxShadow(hasScrolled),
            ),
            padding: edge16WithStatusBar,
            duration: dur240,
            child: Row(
              children: const <Widget>[
                Text(
                  "最新发布",
                  style: textStyle24B,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
