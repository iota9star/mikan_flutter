import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
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
const _fadeDuration = Duration(milliseconds: 600);

@FFRoute(name: '/splash')
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: _splashDuration,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: _fadeDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );

    _controller.forward().then((_) => _navigateToHome());
    _fadeController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
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

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Assets.mikan.image(width: 120.0),
    );
  }

  Widget _buildProgressIndicator() {
    return const PositionedDirectional(
      bottom: 100.0,
      child: ExpressiveLoadingIndicator(),
    );
  }

  Widget _buildSkipText() {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return PositionedDirectional(
          bottom: context.navBarHeight + 36.0,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: PlaceholderText(
              '点击屏幕马上进入',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );
      },
    );
  }

  List<Color> _getBackgroundColorScheme(ThemeData theme) {
    return [
      theme.colorScheme.primary,
      theme.colorScheme.inversePrimary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
    ];
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
              colors: _getBackgroundColorScheme(theme),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildLogo(),
                  _buildProgressIndicator(),
                  _buildSkipText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
