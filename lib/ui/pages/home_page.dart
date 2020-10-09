import 'package:ant_icons/ant_icons.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/providers/models/home_model.dart';
import 'package:mikan_flutter/ui/fragments/index_fragment.dart';
import 'package:mikan_flutter/ui/fragments/list_fragment.dart';
import 'package:mikan_flutter/widget/bottom_bar_view.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "mikan://home",
  routeName: "mikan-home",
)
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Selector<HomeModel, int>(
        builder: (BuildContext context, int selectIndex, Widget child) {
          return IndexedStack(
            children: [
              IndexFragment(),
              ListFragment(),
            ],
            index: selectIndex,
          );
        },
        selector: (_, model) => model.selectedIndex,
        shouldRebuild: (pre, next) => pre != next,
      ),
      bottomNavigationBar: BottomBarView(
        items: [
          BarItem(
            icon: AntIcons.home_outline,
            selectedIcon: AntIcons.home,
            isSelected: true,
          ),
          BarItem(
            icon: AntIcons.ordered_list,
            selectedIcon: AntIcons.unordered_list,
          ),
        ],
        onItemClick: (index) {
          context.read<HomeModel>().selectedIndex = index;
        },
      ),
    );
  }
}
