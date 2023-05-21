import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFArgumentImport()
import 'package:flutter/material.dart';

import '../../internal/extension.dart';
import '../../internal/kit.dart';
import '../../internal/lifecycle.dart';
import '../fragments/index.dart';
import '../fragments/list.dart';
import '../fragments/select_tablet_mode.dart';
import '../fragments/settings.dart';
import '../fragments/subscribed.dart';

@FFRoute(name: '/index')
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      index: _selectedIndex,
      children: const [
        ListFragment(),
        IndexFragment(),
        SubscribedFragment(),
      ],
    );
    return WillPopScope(
      onWillPop: () async {
        const snackBar = SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 400.0,
          content: Text('想要退出？不可能的'),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: '哦',
            onPressed: exitApp,
          ),
        );
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return false;
      },
      child: AnnotatedRegion(
        value: context.fitSystemUiOverlayStyle,
        child: TabletModeBuilder(
          builder: (context, isTablet, child) {
            return Scaffold(
              bottomNavigationBar: !isTablet
                  ? NavigationBar(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.segment_rounded),
                          selectedIcon: Icon(Icons.receipt_long_rounded),
                          label: '最新',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.local_fire_department_rounded),
                          selectedIcon: Icon(Icons.light_rounded),
                          label: '番组',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.person_rounded),
                          selectedIcon: Icon(Icons.perm_identity_rounded),
                          label: '我的',
                        ),
                      ],
                    )
                  : null,
              body: isTablet
                  ? Row(
                      children: [
                        NavigationRail(
                          labelType: NavigationRailLabelType.all,
                          destinations: const [
                            NavigationRailDestination(
                              icon: Icon(Icons.segment_rounded),
                              selectedIcon: Icon(Icons.receipt_long_rounded),
                              label: Text('最新'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.local_fire_department_rounded),
                              selectedIcon: Icon(Icons.light_rounded),
                              label: Text('番组'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.person_rounded),
                              selectedIcon: Icon(Icons.perm_identity_rounded),
                              label: Text('我的'),
                            ),
                          ],
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          groupAlignment: -0.8,
                          leading: Column(
                            children: [
                              SizedBox(height: 16.0 + context.statusBarHeight),
                              buildAvatarWithAction(context),
                              IconButton(
                                onPressed: () {
                                  showSearchPanel(context);
                                },
                                icon: const Icon(Icons.search_rounded),
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(
                          thickness: 0.0,
                          width: 1.0,
                        ),
                        Expanded(child: body),
                      ],
                    )
                  : body,
            );
          },
        ),
      ),
    );
  }
}
