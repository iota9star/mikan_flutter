import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/providers/list_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/components/normal_record_item.dart';
import 'package:mikan_flutter/ui/fragments/index_fragment.dart';
import 'package:mikan_flutter/widget/refresh_indicator.dart';
import 'package:mikan_flutter/widget/sliver_pinned_header.dart';
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
      body: SmartRefresher(
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
    final it = ColorTween(
      begin: theme.backgroundColor,
      end: theme.scaffoldBackgroundColor,
    );
    return SimpleSliverPinnedHeader(
      builder: (context, ratio) {
        final ic = it.transform(ratio);
        return Row(
          children: [
            Expanded(
              child: Text(
                "最新发布",
                style: TextStyle(
                  fontSize: 30.0 - (ratio * 6.0),
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                showSearchPanel(context);
              },
              color: ic,
              minWidth: 32.0,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: circleShape,
              child: const Icon(
                FluentIcons.search_24_regular,
                size: 16.0,
              ),
            ),
          ],
        );
      },
    );
  }
}
