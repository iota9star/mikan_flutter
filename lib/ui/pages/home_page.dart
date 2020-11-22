import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/providers/models/home_model.dart';
import 'package:mikan_flutter/ui/fragments/index_fragment.dart';
import 'package:mikan_flutter/ui/fragments/list_fragment.dart';
import 'package:mikan_flutter/ui/fragments/subscribed_fragment.dart';
import 'package:mikan_flutter/widget/bottom_bar_view.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "home",
  routeName: "home",
  argumentImports: ["import 'package:flutter/material.dart';"],
)
@immutable
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: Scaffold(
        bottomNavigationBar: Selector<HomeModel, int>(
          selector: (_, model) => model.selectedIndex,
          shouldRebuild: (pre, next) => pre != next,
          builder: (_, selectIndex, __) {
            return BottomBarView(
              items: [
                BarItem(
                  icon: FluentIcons.home_24_regular,
                  selectedIconPath: "assets/mikan.png",
                  isSelected: selectIndex == 0,
                ),
                BarItem(
                  icon: FluentIcons.list_24_regular,
                  selectedIcon: FluentIcons.list_24_filled,
                  isSelected: selectIndex == 1,
                ),
                BarItem(
                  icon: FluentIcons.collections_24_regular,
                  selectedIcon: FluentIcons.collections_24_filled,
                  isSelected: selectIndex == 2,
                ),
              ],
              onItemClick: (index) {
                context.read<HomeModel>().selectedIndex = index;
              },
            );
          },
        ),
        body: Selector<HomeModel, int>(
          selector: (_, model) => model.selectedIndex,
          shouldRebuild: (pre, next) => pre != next,
          builder: (_, selectIndex, __) {
            return IndexedStack(
              children: [
                IndexFragment(),
                ListFragment(),
                SubscribedFragment(),
              ],
              index: selectIndex,
            );
          },
        ),
      ),
    );
  }
}
