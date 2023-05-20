import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/image_provider.dart';
import '../../model/bangumi_row.dart';
import '../../providers/index_model.dart';
import '../../topvars.dart';

class BangumiCoverScrollListFragment extends StatefulWidget {
  const BangumiCoverScrollListFragment({super.key});

  @override
  State<StatefulWidget> createState() => _BangumiCoverScrollListFragmentState();
}

const _kRate = 60;
const _kScrollOffset = 360;
const _kScrollDuration =
    Duration(milliseconds: 1000 ~/ _kRate * _kScrollOffset);

class _BangumiCoverScrollListFragmentState
    extends State<BangumiCoverScrollListFragment> {
  final ScrollController _scrollController = ScrollController();

  bool _animating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      if (_animating) {
        return;
      }
      if (_scrollController.hasClients) {
        _animating = true;
        _scrollController
            .animateTo(
          _scrollController.offset + _kScrollOffset,
          duration: _kScrollDuration,
          curve: Curves.linear,
        )
            .whenComplete(() {
          _animating = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Selector<IndexModel, List<BangumiRow>>(
      selector: (_, model) => model.bangumiRows,
      shouldRebuild: (pre, next) => pre.length != next.length,
      builder: (_, bangumiRows, __) {
        return _buildList(theme, bangumiRows);
      },
    );
  }

  Widget _buildList(ThemeData theme, List<BangumiRow> bangumiRows) {
    final bangumis =
        bangumiRows.map((e) => e.bangumis).expand((element) => element);
    final length = bangumis.length;
    if (length == 0) {
      return sizedBox;
    }
    return GridView.builder(
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400.0,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (_, index) {
        final bangumi = bangumis.elementAt(index % length);
        return Image(
          image: CacheImage(bangumi.cover),
          fit: BoxFit.cover,
        );
      },
    );
  }
}
