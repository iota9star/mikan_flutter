import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../internal/delegate.dart';
import '../../internal/kit.dart';
import '../../mikan_routes.dart';
import '../../providers/list_model.dart';
import '../../topvars.dart';
import '../../widget/sliver_pinned_header.dart';
import '../components/list_record_item.dart';
import 'index.dart';
import 'select_tablet_mode.dart';

@immutable
class ListFragment extends StatelessWidget {
  const ListFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = Provider.of<ListModel>(context, listen: false);
    return Scaffold(
      body: EasyRefresh(
        refreshOnStart: true,
        header: defaultHeader,
        footer: defaultFooter(context),
        onRefresh: model.refresh,
        onLoad: model.loadMore,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildList(theme, model),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ThemeData theme, ListModel listModel) {
    return SliverPadding(
      padding: edgeH24V16,
      sliver: Selector<ListModel, int>(
        selector: (_, model) => model.changeFlag,
        shouldRebuild: (pre, next) => pre != next,
        builder: (context, __, ___) {
          final records = listModel.records;
          if (records.isEmpty) {
            return emptySliverToBoxAdapter;
          }
          return SliverWaterfallFlow(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final record = records[index];
                return ListRecordItem(
                  index: index,
                  record: record,
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
            gridDelegate: SliverWaterfallFlowDelegateWithMinCrossAxisExtent(
              crossAxisSpacing: context.margins,
              mainAxisSpacing: context.margins,
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
                  IconButton(
                    onPressed: () {
                      showSearchPanel(context);
                    },
                    icon: const Icon(Icons.search_rounded),
                  )
                ],
        );
      },
    );
  }
}
