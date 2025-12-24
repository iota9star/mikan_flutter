import 'dart:ui';

import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

import '../../internal/extension.dart';
import '../../internal/kit.dart';
import '../../mikan_routes.dart';
import '../../res/assets.gen.dart';
import '../../widget/background.dart';
import '../../widget/placeholder_text.dart';
import '../../widget/ripple_tap.dart';

const _splashDuration = Duration(seconds: 5);

@FFRoute(name: '/splash')
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countdownAnimation;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _splashDuration,
      vsync: this,
    );
    _countdownAnimation = Tween<double>(begin: 5, end: 0).animate(_controller);
    _controller.forward().then((_) => _navigateToHome());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) {
      return;
    }
    _hasNavigated = true;
    Navigator.pushNamedAndRemoveUntil(context, Routes.index.name, (_) => true);
  }

  void _skipCountdown() {
    if (_hasNavigated || !mounted) {
      return;
    }
    _controller.stop();
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: Scaffold(
        body: RippleTap(
          onTap: _skipCountdown,
          child: SizedBox.expand(
            child: BubbleBackground(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.inversePrimary,
                theme.colorScheme.secondary,
                theme.colorScheme.tertiary,
                theme.colorScheme.error,
              ],
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Assets.mikan.image(width: 120.0),
                    PositionedDirectional(
                      bottom: context.navBarHeight + 36.0,
                      child: AnimatedBuilder(
                        animation: _countdownAnimation,
                        builder: (context, child) {
                          final seconds = _countdownAnimation.value.ceil().clamp(1, 5);
                          return PlaceholderText(
                            '点击屏幕马上进入 ($seconds秒)',
                            style: theme.textTheme.bodyMedium,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
