import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mikan_flutter/model/bangumi.dart';
import 'package:mikan_flutter/providers/models/bangumi_details_model.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "mikan://bangumi-home",
  routeName: "bangumi-home",
)
@immutable
class BangumiHomePage extends StatelessWidget {
  final Bangumi bangumi;

  const BangumiHomePage({Key key, this.bangumi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<BangumiHomeModel>(
        create: (context) => BangumiHomeModel(bangumi.id),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [];
          },
          body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Selector<BangumiHomeModel, String>(
              selector: (context, model) => model.bangumiHome?.intro,
              shouldRebuild: (pre, next) => pre != next,
              builder: (context, value, child) {
                return HtmlWidget(value ?? "");
              },
            ),
          ),
        ),
      ),
    );
  }
}
