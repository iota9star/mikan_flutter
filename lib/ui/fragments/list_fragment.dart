import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/providers/list_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/components/normal_record_item.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@immutable
class ListFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ListModel model = Provider.of<ListModel>(context, listen: false);
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
            backgroundColor: theme.accentColor,
            color: theme.accentColor.computeLuminance() < 0.5
                ? Colors.white
                : Colors.black,
            distance: Sz.statusBarHeight + 42.0,
          ),
          footer: Indicator.footer(
            context,
            theme.accentColor,
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
            return sliverToBoxAdapter;
          }
          return SliverGrid(
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
            gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 360.0,
              mainAxisExtent: 16.0,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 164.0,
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
            padding: edge16Header(),
            duration: dur240,
            child: Row(
              children: <Widget>[
                Text(
                  "最新发布",
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
