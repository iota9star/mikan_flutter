import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:ant_icons/ant_icons.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/providers/models/home_model.dart';
import 'package:mikan_flutter/ui/fragments/index_fragment.dart';
import 'package:mikan_flutter/ui/fragments/list_fragment.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "mikan://home",
  routeName: "mikan-home",
)
@immutable
class HomePage extends StatelessWidget {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Selector<HomeModel, int>(
      builder: (BuildContext context, int selectIndex, Widget child) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            children: <Widget>[
              IndexFragment(),
              ListFragment(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              print('hello world.');
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: AnimatedBottomNavigationBar(
            icons: [AntIcons.home, AntIcons.ordered_list],
            activeIndex: selectIndex,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.verySmoothEdge,
            leftCornerRadius: 32,
            rightCornerRadius: 32,
            onTap: (index) => Provider.of<HomeModel>(context).selectedIndex = index,
            //other params
          ),
        );
      },
      selector: (_, model) => model.selectedIndex,
      shouldRebuild: (pre, next) => pre != next,
    );
  }
}
