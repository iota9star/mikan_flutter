import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/image_provider.dart';
import 'package:mikan_flutter/internal/screen.dart';
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
    extends State<BangumiCoverScrollListFragment> {
  final ScrollController _scrollController = ScrollController();

  final _ScrollItemModel _scrollItemModel = _ScrollItemModel();

  bool _animating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPersistentFrameCallback((_) {
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
      _scrollItemModel.scrolling(_scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollItemModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider.value(
      value: _scrollItemModel,
      child: Container(
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
            final bangumis =
                bangumiRows.map((e) => e.bangumis).expand((element) => element);
            final length = bangumis.length;
            if (length == 0) {
              return sizedBox;
            }
            return GridView.builder(
              controller: _scrollController,
              padding: edge8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: _scrollItemModel.maxCrossAxisExtent,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemBuilder: (_, index) {
                final bangumi = bangumis.elementAt(index % length);
                return ExtendedImage(
                  image: FastCacheImage(bangumi.cover),
                  loadStateChanged: (state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                      case LoadState.failed:
                        return sizedBox;
                      case LoadState.completed:
                        return _buildBackgroundCover(
                          bangumi,
                          state.imageProvider,
                          index,
                        );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundCover(
    final Bangumi bangumi,
    final ImageProvider imageProvider,
    final int index,
  ) {
    return Selector<_ScrollItemModel, double>(
      selector: (_, model) => model[index],
      shouldRebuild: (pre, next) => pre != next,
      builder: (_, align, __) {
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

class _ScrollItemModel extends ChangeNotifier {
  late final double maxCrossAxisExtent;
  late final double contentWidth;
  late final int crossAxisCount;
  late final double itemSize;

  double _offset = 0;

  _ScrollItemModel() {
    maxCrossAxisExtent = 208.0;
    contentWidth = Screen.screenWidth - 16.0;
    crossAxisCount = ((contentWidth) / (maxCrossAxisExtent + 8.0)).ceil();
    itemSize =
        (Screen.screenWidth - (crossAxisCount + 1) * 8.0) / crossAxisCount;
  }

  void scrolling(double offset) {
    _offset = offset;
    notifyListeners();
  }

  double operator [](int index) {
    return ((_offset +
                        Screen.screenHeight -
                        index / crossAxisCount * (itemSize + 8.0)) /
                    Screen.screenHeight)
                .clamp(0.0, 1.0) *
            2 -
        1;
  }
}
