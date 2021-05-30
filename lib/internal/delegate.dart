import 'dart:math' as math;

import 'package:extended_list_library/extended_list_library.dart'
    show ViewportBuilder;
import 'package:flutter/material.dart' hide ViewportBuilder;
import 'package:flutter/rendering.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class SliverGridDelegateWithMinCrossAxisExtent extends SliverGridDelegate {
  const SliverGridDelegateWithMinCrossAxisExtent({
    required this.minCrossAxisExtent,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
  })  : assert(minCrossAxisExtent >= 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        assert(childAspectRatio > 0);
  final double minCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;

  bool _debugAssertIsValid(double crossAxisExtent) {
    assert(crossAxisExtent > 0.0);
    assert(minCrossAxisExtent > 0.0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(childAspectRatio > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid(constraints.crossAxisExtent));
    int crossAxisCount =
        (constraints.crossAxisExtent / (minCrossAxisExtent + crossAxisSpacing))
            .floor();
    if (crossAxisCount <= 0) {
      crossAxisCount = 1;
    }
    final double usableCrossAxisExtent = math.max(0.0,
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1));
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent =
        mainAxisExtent ?? childCrossAxisExtent / childAspectRatio;
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithMinCrossAxisExtent oldDelegate) {
    return oldDelegate.minCrossAxisExtent != minCrossAxisExtent ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio ||
        oldDelegate.mainAxisExtent != mainAxisExtent;
  }
}

class SliverWaterfallFlowDelegateWithMinCrossAxisExtent
    extends SliverWaterfallFlowDelegate {
  const SliverWaterfallFlowDelegateWithMinCrossAxisExtent({
    required this.minCrossAxisExtent,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    LastChildLayoutTypeBuilder? lastChildLayoutTypeBuilder,
    CollectGarbage? collectGarbage,
    ViewportBuilder? viewportBuilder,
    bool closeToTrailing = false,
  })  : assert(minCrossAxisExtent >= 0),
        super(
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          lastChildLayoutTypeBuilder: lastChildLayoutTypeBuilder,
          collectGarbage: collectGarbage,
          viewportBuilder: viewportBuilder,
          closeToTrailing: closeToTrailing,
        );

  final double minCrossAxisExtent;

  @override
  int getCrossAxisCount(SliverConstraints constraints) {
    final count =
        (constraints.crossAxisExtent / (minCrossAxisExtent + crossAxisSpacing))
            .floor();
    return count == 0 ? 1 : count;
  }

  @override
  bool shouldRelayout(SliverWaterfallFlowDelegate oldDelegate) {
    if (oldDelegate.runtimeType != runtimeType) {
      return true;
    }

    return oldDelegate is SliverWaterfallFlowDelegateWithMaxCrossAxisExtent &&
        (oldDelegate.maxCrossAxisExtent != minCrossAxisExtent ||
            super.shouldRelayout(oldDelegate));
  }
}
