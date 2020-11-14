import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:kenburns/kenburns.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
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
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Selector<IndexModel, List<BangumiRow>>(
              selector: (_, model) => model.bangumiRows,
              builder: (_, bangumiRows, __) {
                return buildBackgroundKenburns();
              },
            ),
          ),
          Positioned(
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
                  SizedBox(
                    height: 4.0,
                  ),
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
                            blurRadius: 8.0)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildBackgroundKenburns() {
    return Selector<IndexModel, List<BangumiRow>>(
      selector: (_, model) => model.bangumiRows,
      builder: (_, bangumiRows, __) {
        final List<Widget> imags = [];
        outer:
        for (final BangumiRow row in bangumiRows) {
          for (final Bangumi bangumi in row.bangumis) {
            if (bangumi.cover.isNotBlank) {
              imags.add(
                ExtendedImage.network(
                  bangumi.cover,
                  fit: BoxFit.cover,
                ),
              );
              if (imags.length > 16) break outer;
            }
          }
        }
        return imags.isEmpty
            ? Container()
            : KenBurns.multiple(
                maxScale: 1.8,
                children: imags,
                maxAnimationDuration: Duration(milliseconds: 5000),
                minAnimationDuration: Duration(milliseconds: 800),
              );
      },
    );
  }
}
