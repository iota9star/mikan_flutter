import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/widget/icon_button.dart';

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
      end: theme.colorScheme.background,
    );
    final maxHeight = maxExtent ?? Screens.statusBarHeight + 128;
    final minHeight = minExtent ?? Screens.statusBarHeight + 72;
    final offsetHeight = maxHeight - minHeight;
    return SliverPersistentHeader(
      delegate: WrapSliverPersistentHeaderDelegate(
        maxExtent: maxHeight,
        minExtent: minHeight,
        onBuild: (
          BuildContext context,
          double shrinkOffset,
          bool overlapsContent,
        ) {
          final offsetRatio = math.min(shrinkOffset / offsetHeight, 1.0);
          final bgc = bgcTween.transform(offsetRatio);
          return ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
              child: Container(
                decoration: BoxDecoration(color: bgc?.withOpacity(0.87)),
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 10.0,
                ),
                child: Align(
                  alignment: alignment,
                  child: builder(context, offsetRatio),
                ),
              ),
            ),
          );
        },
      ),
      pinned: true,
    );
  }
}

class StackSliverPinnedHeader extends StatelessWidget {
  const StackSliverPinnedHeader({
    Key? key,
    required this.childrenBuilder,
    this.maxExtent,
    this.minExtent,
  }) : super(key: key);

  final List<Widget> Function(BuildContext context, double ratio)
      childrenBuilder;
  final double? maxExtent;
  final double? minExtent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgcTween = ColorTween(
      begin: theme.scaffoldBackgroundColor,
      end: theme.colorScheme.background,
    );
    final maxHeight = maxExtent ?? Screens.statusBarHeight + 136.0;
    final minHeight = minExtent ?? Screens.statusBarHeight + 60.0;
    final offsetHeight = maxHeight - minHeight;
    return SliverPersistentHeader(
      delegate: WrapSliverPersistentHeaderDelegate(
        maxExtent: maxHeight,
        minExtent: minHeight,
        onBuild: (
          BuildContext context,
          double shrinkOffset,
          bool overlapsContent,
        ) {
          final offsetRatio = math.min(shrinkOffset / offsetHeight, 1.0);
          final bgc = bgcTween.transform(offsetRatio);
          return ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 16.0, sigmaX: 16.0),
              child: Container(
                decoration: BoxDecoration(color: bgc?.withOpacity(0.87)),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Stack(
                  children: childrenBuilder(context, offsetRatio),
                ),
              ),
            ),
          );
        },
      ),
      pinned: true,
    );
  }
}

class SliverPinnedTitleHeader extends StatelessWidget {
  const SliverPinnedTitleHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final it = ColorTween(
      begin: theme.colorScheme.background,
      end: theme.scaffoldBackgroundColor,
    );
    return StackSliverPinnedHeader(
      childrenBuilder: (context, ratio) {
        final ic = it.transform(ratio);
        return [
          Positioned(
            left: 0,
            top: 12.0 + Screens.statusBarHeight,
            child: CircleBackButton(color: ic),
          ),
          Positioned(
            top: 78.0 * (1 - ratio) + 18.0 + Screens.statusBarHeight,
            left: ratio * 56.0,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 24.0 - (ratio * 4.0),
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ];
      },
    );
  }
}

class WrapSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  WrapSliverPersistentHeaderDelegate({
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
