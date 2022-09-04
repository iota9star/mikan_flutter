import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/screen.dart';

class SimpleSliverPinnedHeader extends StatelessWidget {
  const SimpleSliverPinnedHeader({
    Key? key,
    required this.builder,
    this.alignment = AlignmentDirectional.bottomStart,
    this.maxExtent,
    this.minExtent,
  }) : super(key: key);

  final Widget Function(
    BuildContext context,
    double offsetRatio,
  ) builder;

  final AlignmentGeometry alignment;

  final double? maxExtent;
  final double? minExtent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgcTween = ColorTween(
      begin: theme.scaffoldBackgroundColor,
      end: theme.backgroundColor,
    );
    final maxHeight = maxExtent ?? Screen.statusBarHeight + 128;
    final minHeight = minExtent ?? Screen.statusBarHeight + 72;
    final offsetHeight = maxHeight - minHeight;
    return SliverPersistentHeader(
      delegate: SimpleSliverPersistentHeaderDelegate(
        maxExtent: maxHeight,
        minExtent: minHeight,
        onBuild: (
          BuildContext context,
          double shrinkOffset,
          bool overlapsContent,
        ) {
          final offsetRatio = math.min(shrinkOffset / offsetHeight, 1.0);
          final bgc = bgcTween.transform(offsetRatio);
          final radius = Radius.circular(16.0 * offsetRatio);
          final shadowRadius = 3.0 * offsetRatio;
          return Container(
            decoration: BoxDecoration(
              color: bgc,
              borderRadius: BorderRadius.only(
                bottomLeft: radius,
                bottomRight: radius,
              ),
              boxShadow: offsetRatio == 0
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.024),
                        offset: const Offset(0, 1),
                        blurRadius: shadowRadius,
                        spreadRadius: shadowRadius,
                      ),
                    ],
            ),
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 10.0,
            ),
            child: Align(
              alignment: alignment,
              child: builder(context, offsetRatio),
            ),
          );
        },
      ),
      pinned: true,
    );
  }
}

class SimpleSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  SimpleSliverPersistentHeaderDelegate({
    required this.maxExtent,
    required this.minExtent,
    required this.onBuild,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return onBuild(context, shrinkOffset, overlapsContent);
  }

  @override
  final double maxExtent;
  @override
  final double minExtent;
  final Function(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) onBuild;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
