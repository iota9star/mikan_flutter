import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/providers/home_model.dart';
import 'package:mikan_flutter/ui/fragments/index_fragment.dart';
import 'package:mikan_flutter/ui/fragments/list_fragment.dart';
import 'package:mikan_flutter/ui/fragments/subscribed_fragment.dart';
import 'package:mikan_flutter/widget/bottom_bar_view.dart';
import 'package:provider/provider.dart';

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
        body: Stack(
          children: [
            Positioned.fill(
              child: Selector<HomeModel, int>(
                selector: (_, model) => model.selectedIndex,
                shouldRebuild: (pre, next) => pre != next,
                builder: (_, selectIndex, __) {
                  return IndexedStack(
                    children: [
                      ListFragment(),
                      IndexFragment(),
                      SubscribedFragment(),
                    ],
                    index: selectIndex,
                  );
                },
              ),
            ),
            Positioned(
              bottom: 16.0,
              left: 24.0,
              right: 24.0,
              child: Selector<HomeModel, int>(
                selector: (_, model) => model.selectedIndex,
                shouldRebuild: (pre, next) => pre != next,
                builder: (_, selectIndex, __) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560.0),
                      child: BottomBarView(
                        items: [
                          BarItem(
                            icon: FluentIcons.layer_24_regular,
                            selectedIcon: FluentIcons.link_square_24_filled,
                            isSelected: selectIndex == 0,
                          ),
                          BarItem(
                            icon: FluentIcons.sticker_24_regular,
                            selectedIconPath: "assets/mikan.png",
                            isSelected: selectIndex == 1,
                          ),
                          BarItem(
                            icon: FluentIcons.leaf_one_24_regular,
                            selectedIcon: FluentIcons.leaf_three_24_filled,
                            isSelected: selectIndex == 2,
                          ),
                        ],
                        onItemClick: (index) {
                          context.read<HomeModel>().selectedIndex = index;
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
