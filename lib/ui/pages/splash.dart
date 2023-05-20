import 'dart:async';

import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

import '../../internal/extension.dart';
import '../../internal/kit.dart';
import '../../mikan_routes.dart';
import '../../topvars.dart';
import '../fragments/bangumi_cover_scroll_list.dart';

@FFRoute(name: '/splash')
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 6), () {
      Navigator.pushReplacementNamed(context, Routes.index.name);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: lightSystemUiOverlayStyle,
      child: Scaffold(
        body: _buildSplash(context),
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushReplacementNamed(context, Routes.index.name);
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/mikan.png',
            width: 42.0,
            isAntiAlias: true,
          ),
          sizedBoxW12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mikan Project',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '点我进入',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSplash(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        const Positioned.fill(child: BangumiCoverScrollListFragment()),
        PositionedDirectional(
          bottom: 36.0 + context.navBarHeight,
          child: _buildAppIcon(context),
        ),
      ],
    );
  }
}
