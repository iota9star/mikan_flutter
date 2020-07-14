import 'package:cached_network_image/cached_network_image.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:kenburns/kenburns.dart';
import 'package:mikan_flutter/ext/extension.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/model/bangumi_row.dart';
import 'package:mikan_flutter/providers/models/index_model.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "mikan://splash",
  routeName: "mikan-splash",
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
                CachedNetworkImage(
                  imageUrl: bangumi.cover,
                  fit: BoxFit.cover,
                ),
              );
              if (imags.length > 6) break outer;
            }
          }
        }
        return imags.isEmpty
            ? Container()
            : KenBurns.multiple(
                maxScale: 1.5,
                children: imags,
              );
      },
    );
  }
}
