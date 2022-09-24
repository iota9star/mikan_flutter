import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:provider/provider.dart';

class BangumiCoverScrollListFragment extends StatefulWidget {
  const BangumiCoverScrollListFragment({Key? key}) : super(key: key);

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
      if (_animating) return;
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
    return Container(
      foregroundDecoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.black12, Colors.black87],
          stops: [0, 0.72, 1.0],
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, theme.backgroundColor],
        ),
      ),
      child: Selector<IndexModel, List<BangumiRow>>(
        selector: (_, model) => model.bangumiRows,
        shouldRebuild: (pre, next) => pre.length != next.length,
        builder: (_, bangumiRows, __) {
          return _buildList(bangumiRows);
        },
      ),
    );
  }

  Widget _buildList(List<BangumiRow> bangumiRows) {
    final bangumis =
        bangumiRows.map((e) => e.bangumis).expand((element) => element);
    final length = bangumis.length;
    if (length == 0) {
      return sizedBox;
    }
    return GridView.builder(
      controller: _scrollController,
      padding: edge16,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (_, index) {
        final bangumi = bangumis.elementAt(index % length);
        return Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius8,
            image: DecorationImage(
              image: CacheImageProvider(bangumi.cover),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
