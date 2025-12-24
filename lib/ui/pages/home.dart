import 'dart:math' as math;

import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
@FFAutoImport()
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/extension.dart';
import '../../internal/kit.dart';
import '../../internal/lifecycle.dart';
import '../../providers/home_model.dart';
import '../../widget/md3_navigation_bar.dart';
import '../../widget/transition_container.dart';
import '../fragments/index.dart';
import '../fragments/list.dart';
import '../fragments/select_tablet_mode.dart';
import '../fragments/settings.dart';
import '../fragments/subscribed.dart';
import 'search.dart';

@FFRoute(name: '/index')
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    Provider.of<HomeModel>(context, listen: false).checkAppVersion();
  }

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      index: _selectedIndex,
      children: const [ListFragment(), IndexFragment(), SubscribedFragment()],
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        const snackBar = SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 320.0,
          content: Text('确定要退出应用吗？'),
          duration: Duration(seconds: 3),
          action: SnackBarAction(label: '退出', onPressed: exitApp),
        );
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: AnnotatedRegion(
        value: context.fitSystemUiOverlayStyle,
        child: TabletModeBuilder(
          builder: (context, isTablet, child) {
            return Scaffold(
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
                              TransitionContainer(
                                next: const SearchPage(),
                                builder: (context, open) {
                                  return IconButton(onPressed: open, icon: const Icon(Icons.search_rounded));
                                },
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(thickness: 0.0, width: 1.0),
                        Expanded(child: body),
                      ],
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(child: body),
                        Positioned(
                          bottom: math.max(28.0, context.navBarHeight + 8.0),
                          child: SizedBox(
                            width: 230.0,
                            child: M3NavigationBar(
                              selectedIndex: _selectedIndex,
                              onDestinationSelected: (index) {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              items: const [
                                M3NavigationItem(
                                  icon: Icons.segment_rounded,
                                  selectedIcon: Icons.receipt_long_rounded,
                                  label: '最新',
                                ),
                                M3NavigationItem(
                                  icon: Icons.local_fire_department_rounded,
                                  selectedIcon: Icons.light_rounded,
                                  label: '番组',
                                ),
                                M3NavigationItem(
                                  icon: Icons.person_rounded,
                                  selectedIcon: Icons.perm_identity_rounded,
                                  label: '我的',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
