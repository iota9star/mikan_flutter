import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/ui.dart';
import 'package:mikan_flutter/ui/fragments/index_fragment.dart';

@FFRoute(
  name: "home",
  routeName: "home",
)
@immutable
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: Scaffold(
        // bottomNavigationBar: BottomBarView(
        //   items: [
        //     BarItem(
        //       icon: FluentIcons.home_24_regular,
        //       selectedIconPath: "assets/mikan.png",
        //       isSelected: true,
        //     ),
        //     BarItem(
        //       icon: FluentIcons.list_24_regular,
        //       selectedIcon: FluentIcons.list_24_filled,
        //     ),
        //   ],
        //   onItemClick: (index) {
        //     context.read<HomeModel>().selectedIndex = index;
        //   },
        // ),
        // body: Selector<HomeModel, int>(
        //   builder: (BuildContext context, int selectIndex, Widget child) {
        //     return IndexedStack(
        //       children: [
        //         IndexFragment(),
        //         ListFragment(),
        //       ],
        //       index: selectIndex,
        //     );
        //   },
        //   selector: (_, model) => model.selectedIndex,
        //   shouldRebuild: (pre, next) => pre != next,
        // ),
        body: IndexFragment(),
      ),
    );
  }
}
