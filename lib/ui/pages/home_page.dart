import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/ui/fragments/index_fragment.dart';
import 'package:mikan_flutter/ui/fragments/list_fragment.dart';

@FFRoute(
  name: "mikan://home",
  routeName: "mikan-home",
)
@immutable
class HomePage extends StatelessWidget {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          IndexFragment(),
          ListFragment(),
        ],
      ),
    );
  }
}
