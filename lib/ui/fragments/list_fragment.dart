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
import 'package:mikan_flutter/widget/icon_button.dart';
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
          distance: Screens.statusBarHeight + 42.0,
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
            _buildHeader(),
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
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              minCrossAxisExtent: 360.0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return const _PinedHeader();
  }
}

class _PinedHeader extends StatelessWidget {
  const _PinedHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final it = ColorTween(
      begin: theme.backgroundColor,
      end: theme.scaffoldBackgroundColor,
    );
    return StackSliverPinnedHeader(
      childrenBuilder: (context, ratio) {
        final ic = it.transform(ratio);
        return [
          Positioned(
            right: 0,
            top: 12.0 + Screens.statusBarHeight,
            child: SmallCircleButton(
              icon: Icons.search_rounded,
              color: ic,
              onTap: () {
                showSearchPanel(context);
              },
            ),
          ),
          Positioned(
            top: 78.0 * (1 - ratio) + 18.0 + Screens.statusBarHeight,
            left: 0.0,
            child: Text(
              "最新发布",
              style: TextStyle(
                fontSize: 24.0 - (ratio * 4.0),
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ];
      },
    );
  }
}
