import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/delegate.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/state.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "splash",
  routeName: "/splash",
)
class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends PageState<SplashPage> {
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
    return Scaffold(
      body: _buildSplash(context),
    );
  }

  Positioned _buildAppIcon(final BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 128.0,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              child: ExtendedImage.asset(
                "assets/mikan.png",
                width: 108,
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, Routes.home);
              },
            ),
            sizedBoxH4,
            Text(
              "蜜柑计划",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.white.withOpacity(0.87),
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8.0,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplash(final BuildContext context) {
    return Selector<IndexModel, List<BangumiRow>>(
      selector: (_, model) => model.bangumiRows,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, bangumiRows, __) {
        final bangumis = bangumiRows
            .map((e) => e.bangumis)
            .expand((element) => element)
            .toList()
              ..shuffle();
        final length = bangumis.length;
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Container(
                foregroundDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.black12, Colors.black87],
                    stops: [0, 0.72, 1.0],
                  ),
                ),
                child: GridView.builder(
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
                ),
              ),
            ),
            _buildAppIcon(context)
          ],
        );
      },
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
