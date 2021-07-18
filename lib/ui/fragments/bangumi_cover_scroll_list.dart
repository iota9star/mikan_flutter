import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
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

const _kRate = 60;
const _kScrollOffset = 360;
const _kScrollDuration =
    const Duration(milliseconds: 1000 ~/ _kRate * _kScrollOffset);

class _BangumiCoverScrollListFragmentState
    extends PageState<BangumiCoverScrollListFragment> {
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<double> _scrollNotifier = ValueNotifier(0);

  bool _animating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPersistentFrameCallback((callback) {
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
    _scrollController.addListener(() {
      _scrollNotifier.value = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxCrossAxisExtent = 208.0;
    final contentWidth = Screen.screenWidth - 16.0;
    final crossAxisCount = ((contentWidth) / (maxCrossAxisExtent + 8.0)).ceil();
    final itemSize =
        (Screen.screenWidth - (crossAxisCount + 1) * 8.0) / crossAxisCount;
    final theme = Theme.of(context);
    return Container(
      foregroundDecoration: BoxDecoration(
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
            padding: edge8,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCrossAxisExtent,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
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
                        index,
                        crossAxisCount,
                        itemSize,
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
    final int index,
    final int crossAxisCount,
    final double itemSize,
  ) {
    return ValueListenableBuilder(
      valueListenable: _scrollNotifier,
      builder: (_, double value, __) {
        final double scrolledRowHeight =
            index / crossAxisCount * (itemSize + 8.0);
        final double align =
            ((value + Screen.screenHeight - scrolledRowHeight) /
                            Screen.screenHeight)
                        .clamp(0.0, 1.0) *
                    2 -
                1;
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              alignment: Alignment(align, align),
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
