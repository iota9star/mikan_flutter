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
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  AnimationController _animationController;
  Animation<double> animation;
  CurvedAnimation curve;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    curve = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.5,
        1.0,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curve);

    Future.delayed(
      Duration(seconds: 1),
      () => _animationController.forward(),
    );
  }

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
          floatingActionButton: ScaleTransition(
            scale: animation,
            child: FloatingActionButton(
              elevation: 8,
              child: Icon(
                Icons.brightness_3,
              ),
              onPressed: () {
                _animationController.reset();
                _animationController.forward();
              },
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: AnimatedBottomNavigationBar(
            icons: [AntIcons.home, AntIcons.ordered_list],
            activeIndex: selectIndex,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.defaultEdge,
            notchAndCornersAnimation: animation,
            splashSpeedInMilliseconds: 300,
            leftCornerRadius: 32,
            rightCornerRadius: 32,
            onTap: (index) =>
                Provider.of<HomeModel>(context).selectedIndex = index,
            //other params
          ),
        );
      },
      selector: (_, model) => model.selectedIndex,
      shouldRebuild: (pre, next) => pre != next,
    );
  }
}
