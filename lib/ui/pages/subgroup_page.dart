import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/internal/ui.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/model/subgroup_gallery.dart';
import 'package:mikan_flutter/providers/models/subgroup_model.dart';
import 'package:mikan_flutter/ui/fragments/bangumi_sliver_grid_fragment.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "subgroup",
  routeName: "subgroup",
)
@immutable
class SubgroupPage extends StatelessWidget {
  final Subgroup subgroup;

  const SubgroupPage({Key key, this.subgroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).backgroundColor;
    final Color scaffoldBackgroundColor =
        Theme.of(context).scaffoldBackgroundColor;
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => SubgroupModel(subgroup),
          child: Builder(
            builder: (context) {
              final SubgroupModel subgroupModel =
                  Provider.of<SubgroupModel>(context, listen: false);
              return NotificationListener(
                onNotification: (notification) {
                  if (notification is OverscrollIndicatorNotification) {
                    notification.disallowGlow();
                  } else if (notification is ScrollUpdateNotification) {
                    if (notification.depth == 0) {
                      final double offset = notification.metrics.pixels;
                      context.read<SubgroupModel>().hasScrolled = offset > 0;
                    }
                  }
                  return true;
                },
                child: Selector<SubgroupModel, List<SubgroupGallery>>(
                  selector: (_, model) => model.galleries,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (context, galleries, __) {
                    return CustomScrollView(
                      slivers: [
                        Selector<SubgroupModel, bool>(
                          selector: (_, model) => model.hasScrolled,
                          builder: (_, hasScrolled, __) {
                            return SliverPinnedToBoxAdapter(
                              child: AnimatedContainer(
                                decoration: BoxDecoration(
                                  color: hasScrolled
                                      ? backgroundColor
                                      : scaffoldBackgroundColor,
                                  boxShadow: hasScrolled
                                      ? [
                                    BoxShadow(
                                      color:
                                      Colors.black.withOpacity(0.024),
                                      offset: Offset(0, 1),
                                      blurRadius: 3.0,
                                      spreadRadius: 3.0,
                                    ),
                                  ]
                                      : null,
                                  borderRadius: hasScrolled
                                      ? BorderRadius.only(
                                    bottomLeft: Radius.circular(16.0),
                                    bottomRight: Radius.circular(16.0),
                                  )
                                      : null,
                                ),
                                padding: EdgeInsets.only(
                                  top: 16.0 + Sz.statusBarHeight,
                                  left: 16.0,
                                  right: 16.0,
                                  bottom: 16.0,
                                ),
                                duration: Duration(milliseconds: 240),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      subgroup.name,
                                      style: TextStyle(
                                        fontSize: 28,
                                        height: 1.25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        if (subgroupModel.loading)
                          SliverFillRemaining(
                            child: Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          ),
                        if (galleries.isSafeNotEmpty)
                          ...List.generate(galleries.length, (index) {
                            final SubgroupGallery gallery = galleries[index];
                            final String section =
                                "${gallery.date} ${gallery.season}";
                            return <Widget>[
                              SliverToBoxAdapter(
                                child: Container(
                                  padding: EdgeInsets.only(
                                    top: 16.0,
                                    left: 16.0,
                                    right: 16.0,
                                    bottom: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scaffoldBackgroundColor,
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     offset: Offset(0, 4.0),
                                    //     blurRadius: 12.0,
                                    //     spreadRadius: -12.0,
                                    //     color: Colors.black26,
                                    //   )
                                    // ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          section,
                                          style: TextStyle(
                                            fontSize: 20,
                                            height: 1.25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // Tooltip(
                                      //   message: full,
                                      //   child: Text(
                                      //     simple,
                                      //     style: TextStyle(
                                      //       color: Theme.of(context)
                                      //           .textTheme
                                      //           .bodyText1
                                      //           .color,
                                      //       fontSize: 12.0,
                                      //       height: 1.25,
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                              BangumiSliverGridFragment(
                                flag: section,
                                bangumis: gallery.bangumis,
                              ),
                            ];
                          }).expand((element) => element),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
