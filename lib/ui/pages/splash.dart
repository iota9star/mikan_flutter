import 'dart:async';
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

@FFRoute(name: '/splash')
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  final _counter = ValueNotifier(5);

  @override
  void initState() {
    super.initState();
    int second = 5;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (--second == 0) {
        timer.cancel();
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.index.name,
          (_) => true,
        );
      }
      _counter.value = second;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: Scaffold(
        body: RippleTap(
          onTap: () {
            _timer?.cancel();
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.index.name,
              (_) => true,
            );
          },
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
                      child: ValueListenableBuilder(
                        valueListenable: _counter,
                        builder: (context, v, child) {
                          return PlaceholderText(
                            '点击屏幕马上进入 ({$v秒})',
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
