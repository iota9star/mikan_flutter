import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mikan_flutter/providers/models/bangumi_details_model.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "mikan://bangumi-details",
  routeName: "bangumi-details",
  argumentNames: ["title", "url", "name", "cover"],
)
@immutable
class BangumiDetailsPage extends StatelessWidget {
  final String url;
  final String title;
  final String cover;
  final String name;

  const BangumiDetailsPage(
      {Key key, this.url, this.title, this.cover, this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<BangumiDetailsModel>(
        create: (context) => BangumiDetailsModel(this.url),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [];
          },
          body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Selector<BangumiDetailsModel, String>(
              selector: (context, model) => model.bangumiDetails?.intro,
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
