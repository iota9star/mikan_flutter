import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/state.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:provider/provider.dart';

class BangumiCoverScrollListFragment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BangumiCoverScrollListFragmentState();

  const BangumiCoverScrollListFragment();
}

class _BangumiCoverScrollListFragmentState
    extends PageState<BangumiCoverScrollListFragment> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((callback) {
      WidgetsBinding.instance!.addPersistentFrameCallback((callback) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.offset + 1,
            duration: Duration(milliseconds: 1000 ~/ 60),
            curve: Curves.linear,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(final BuildContext context) {
    return Container(
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.black12, Colors.black87],
          stops: [0, 0.72, 1.0],
        ),
      ),
      child: Selector<IndexModel, List<BangumiRow>>(
        selector: (_, model) => model.bangumiRows,
        shouldRebuild: (pre, next) => pre.ne(next),
        builder: (_, bangumiRows, __) {
          final bangumis = bangumiRows
              .map((e) => e.bangumis)
              .expand((element) => element)
              .toList()
                ..shuffle();
          final length = bangumis.length;
          return GridView.builder(
            controller: _scrollController,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 160.0,
            ),
            itemBuilder: (_, index) {
              final bangumi = bangumis[index % length];
              return ExtendedImage.network(
                bangumi.cover,
                loadStateChanged: (state) {
                  Widget child;
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      child = _buildBangumiItemPlaceholder();
                      break;
                    case LoadState.completed:
                      child = _buildBackgroundCover(
                        bangumi,
                        state.imageProvider,
                      );
                      break;
                    case LoadState.failed:
                      child = _buildBangumiItemError();
                      break;
                  }
                  return child;
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBangumiItemPlaceholder() {
    return Container(
      padding: edge28,
      child: Center(
        child: ExtendedImage.asset(
          "assets/mikan.png",
        ),
      ),
    );
  }

  Widget _buildBangumiItemError() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ExtendedAssetImageProvider("assets/mikan.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBackgroundCover(
    final Bangumi bangumi,
    final ImageProvider imageProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
