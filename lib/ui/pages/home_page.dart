import 'package:ant_icons/ant_icons.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/ext/state.dart';
import 'package:mikan_flutter/providers/models/home_model.dart';
import 'package:mikan_flutter/ui/fragments/index_fragment.dart';
import 'package:mikan_flutter/ui/fragments/list_fragment.dart';
import 'package:mikan_flutter/widget/bottom_bar_view.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "mikan://home",
  routeName: "mikan-home",
)
@immutable
class HomePage extends CacheStatelessWidget {
  @override
  Widget buildCacheWidget(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBarView(
        items: [
          BarItem(
            icon: AntIcons.home_outline,
            selectedIconPath: "assets/mikan.png",
            isSelected: true),
          BarItem(
            icon: AntIcons.block_outline,
            selectedIcon: AntIcons.build,
          ),
        ],
        onItemClick: (index) {
          context.read<HomeModel>().selectedIndex = index;
        },
      ),
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
    );
  }
}
