import 'dart:math' as Math;

import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/providers/index_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "splash",
  routeName: "splash",
)
@immutable
class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSplash(context),
    );
  }

  Positioned _buildAppIcon(final BuildContext context) {
    return Positioned(
      bottom: 96,
      left: 0,
      right: 0,
      child: Container(
        child: Column(
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
                fontSize: 24.0,
                color: Colors.white,
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
    final double itemSize = Sz.screenWidth / 3;
    final int row = Sz.screenHeight ~/ itemSize;
    final int coverCount = 3 * row;
    return Selector<IndexModel, List<BangumiRow>>(
      selector: (_, model) => model.bangumiRows,
      shouldRebuild: (pre, next) => pre.ne(next),
      builder: (_, bangumiRows, __) {
        final List<Widget> covers = [];
        final bangumis = bangumiRows
            .map((e) => e.bangumis)
            .expand((element) => element)
            .take(coverCount);
        for (int i = 0; i < bangumis.length; i++) {
          final String cover = bangumis.elementAt(i).cover;
          final double size =
              itemSize + Math.Random().nextDouble() * itemSize / 3 * factor();
          final double left = itemSize * (i % 3) +
              Math.Random().nextDouble() * itemSize / 2.5 * factor();
          final double top =
              itemSize * (i ~/ 3) + Math.Random().nextDouble() * itemSize / 2.5;
          covers.add(
            Positioned(
              left: left,
              top: top,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: ExtendedNetworkImageProvider(cover),
                  ),
                ),
              ),
            ),
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [...covers..shuffle(), _buildAppIcon(context)],
        );
      },
    );
  }

  int factor() => Math.Random().nextBool() ? 1 : -1;
}
