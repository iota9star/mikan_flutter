import 'dart:async';

import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

import '../../internal/extension.dart';
import '../../internal/kit.dart';
import '../../mikan_routes.dart';
import '../../res/assets.gen.dart';
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
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.index.name,
        (_) => true,
      );
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
        _timer?.cancel();
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.index.name,
          (_) => true,
        );
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.mikan.image(width: 42.0),
          sizedBoxW12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '马上进入',
                style: theme.textTheme.titleMedium!.copyWith(height: 1.24),
              ),
              Text(
                'Mikan Project',
                style: theme.textTheme.bodySmall!.copyWith(height: 1.25),
              ),
            ],
          ),
        ],
      ),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 12.0),
    );
  }

  Widget _buildSplash(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        const Positioned.fill(child: BangumiCoverScrollListFragment()),
        PositionedDirectional(
          bottom: context.screenHeight * 0.06,
          child: _buildAppIcon(context),
        ),
      ],
    );
  }
}
