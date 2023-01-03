import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/ui/fragments/index_fragment.dart';
import 'package:mikan_flutter/ui/fragments/list_fragment.dart';
import 'package:mikan_flutter/ui/fragments/subscribed_fragment.dart';
import 'package:mikan_flutter/widget/bottom_bar_view.dart';

@FFRoute(
  name: "home",
  routeName: "/",
)
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _selectedIndex,
                children: const [
                  ListFragment(),
                  IndexFragment(),
                  SubscribedFragment(),
                ],
              ),
            ),
            Positioned(
              bottom: 8.0 + Screens.navBarHeight,
              left: 24.0,
              right: 24.0,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300.0),
                  child: BottomBarView(
                    items: [
                      BarItem(
                        icon: Icons.segment_rounded,
                        selectedIcon: Icons.receipt_long_rounded,
                        isSelected: _selectedIndex == 0,
                      ),
                      BarItem(
                        icon: Icons.local_fire_department_rounded,
                        selectedIconPath: "assets/mikan.png",
                        isSelected: _selectedIndex == 1,
                      ),
                      BarItem(
                        icon: Icons.person_rounded,
                        selectedIcon: Icons.perm_identity_rounded,
                        isSelected: _selectedIndex == 2,
                      ),
                    ],
                    onItemClick: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
