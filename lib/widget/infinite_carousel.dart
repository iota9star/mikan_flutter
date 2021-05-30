library infinite_carousel;

import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// Default duration and Curve for animateToItem, nextPage and previousPage.
const Duration _kDefaultDuration = Duration(milliseconds: 300);
const Curve _kDefaultCurve = Curves.ease;

/// `Infinite Carousel`
///
/// Based on [ListWheelScrollView] to create smooth scroll effect and physics.
class InfiniteCarousel extends StatefulWidget {
  /// `Infinite Carousel`
  ///
  /// Based on [ListWheelScrollView] to create smooth scroll effect and physics.
  InfiniteCarousel.builder({
    Key? key,
    required this.itemCount,
    required this.itemExtent,
    required this.itemBuilder,
    this.physics,
    this.controller,
    this.onIndexChanged,
    this.anchor = 0.0,
    this.loop = true,
    this.velocityFactor = 0.2,
    this.axisDirection = Axis.horizontal,
    this.center = true,
  })  : assert(itemExtent > 0),
        assert(itemCount > 0),
        assert(velocityFactor > 0.0 && velocityFactor <= 1.0),
        childDelegate = SliverChildBuilderDelegate(
          (context, index) =>
              itemBuilder(context, index.abs() % itemCount, index),
          childCount: loop ? null : itemCount,
        ),
        reversedChildDelegate = loop
            ? SliverChildBuilderDelegate((context, index) => itemBuilder(
                context,
                itemCount - (index.abs() % itemCount) - 1,
                -(index + 1)))
            : null,
        super(key: key);

  /// Total items to build for the carousel.
  final int itemCount;

  /// Maximum width for single item in viewport.
  final double itemExtent;

  /// To lazily build items on the viewport.
  ///
  /// When Loop: false, ItemIndex is equal to RealIndex (i.e, index of element).
  ///
  /// When loop: true, two indexes are exposed by item builder.
  ///
  /// One is `itemIndex`, that is the modded item index i.e., for list of 10, position(11) = 1, and position(-1) = 9.
  ///
  /// Other is `realIndex`, that is the actual index, i.e. [..., -2, -1, 0, 1, 2, ...] in loop.
  /// Real Index is needed if you want to support JumpToItem by tapping on it.
  final Widget Function(BuildContext context, int itemIndex, int realIndex)
      itemBuilder;

  /// Delegate to lazily build items in forward direction.
  final SliverChildDelegate? childDelegate;

  /// Delegate to lazily build items in reverse direction.
  final SliverChildDelegate? reversedChildDelegate;

  /// Physics for [InfiniteCarousel]. Defaults to [InfiniteScrollPhysics], which makes sure we always land on a
  /// particular item after scrolling.
  final ScrollPhysics? physics;

  /// Scroll controller for [InfiniteScrollPhysics].
  final ScrollController? controller;

  /// Callback fired when item is changed.
  final void Function(int)? onIndexChanged;

  /// Where to place selected item on the viewport. Ranges from 0 to 1.
  ///
  /// 0.0 means selected item is aligned to start of the viewport, and
  /// 1.0 meaning selected item is aligned to end of the viewport.
  /// Defaults to 0.0.
  ///
  /// This property is ignored when center is set to true.
  final double anchor;

  /// Weather to create a infinite looping list. Defaults to true.
  final bool loop;

  /// Axis direction of carousel. Defaults to `horizontal`.
  final Axis axisDirection;

  /// Multiply velocity of carousel scrolling by this factor. Defaults to 0.2.
  final double velocityFactor;

  /// Align selected item to center of the viewport. When this is true, anchor property is ignored.
  final bool center;

  @override
  _InfiniteCarouselState createState() => _InfiniteCarouselState();
}

class _InfiniteCarouselState extends State<InfiniteCarousel> {
  final Key _forwardListKey = ValueKey<String>('infinite_carousel_key');
  late InfiniteScrollController scrollController;
  late int _lastReportedItemIndex;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      scrollController = widget.controller as InfiniteScrollController;
    } else {
      scrollController = InfiniteScrollController();
    }
    _lastReportedItemIndex = scrollController.initialItem;
  }

  List<Widget> _buildSlivers() {
    Widget forward = SliverFixedExtentList(
        key: _forwardListKey,
        delegate: widget.childDelegate!,
        itemExtent: widget.itemExtent);

    if (!widget.loop) return [forward];

    Widget reversed = SliverFixedExtentList(
        delegate: widget.reversedChildDelegate!, itemExtent: widget.itemExtent);
    return [reversed, forward];
  }

  AxisDirection _getDirection(BuildContext context) {
    switch (widget.axisDirection) {
      case Axis.horizontal:
        assert(debugCheckHasDirectionality(context));
        final TextDirection textDirection = Directionality.of(context);
        final AxisDirection axisDirection =
            textDirectionToAxisDirection(textDirection);
        return axisDirection;
      case Axis.vertical:
        return AxisDirection.down;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (ScrollUpdateNotification notification) {
        if (widget.onIndexChanged != null) {
          final InfiniteExtentMetrics metrics =
              notification.metrics as InfiniteExtentMetrics;
          final int currentItem = metrics.itemIndex;
          if (currentItem != _lastReportedItemIndex) {
            _lastReportedItemIndex = currentItem;
            final int trueIndex =
                _getTrueIndex(_lastReportedItemIndex, widget.itemCount);
            if (widget.onIndexChanged != null) {
              widget.onIndexChanged!(trueIndex);
            }
          }
        }
        return false;
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final _centeredAnchor = _getCenteredAnchor(constraints);

          return _InfiniteScrollable(
            controller: scrollController,
            itemExtent: widget.itemExtent,
            loop: widget.loop,
            velocityFactor: widget.velocityFactor,
            itemCount: widget.itemCount,
            physics: widget.physics ?? InfiniteScrollPhysics(),
            axisDirection: axisDirection,
            viewportBuilder: (BuildContext context, ViewportOffset position) {
              return Viewport(
                center: _forwardListKey,
                anchor: _centeredAnchor,
                axisDirection: axisDirection,
                offset: position,
                slivers: _buildSlivers(),
              );
            },
          );
        },
      ),
    );
  }

  // Get anchor for viewport to place the item in exact center.
  double _getCenteredAnchor(BoxConstraints constraints) {
    if (!widget.center) return widget.anchor;

    final total = widget.axisDirection == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
    return ((total / 2) - (widget.itemExtent / 2)) / total;
  }
}

/// Extend Scrollable to also include viewport children's itemExtent, itemCount, loop and other values.
/// This is done so that ScrollPosition and Physics can also access these values via scroll context.
class _InfiniteScrollable extends Scrollable {
  const _InfiniteScrollable({
    Key? key,
    AxisDirection axisDirection = AxisDirection.right,
    ScrollController? controller,
    ScrollPhysics? physics,
    required this.itemExtent,
    required this.itemCount,
    required this.loop,
    required this.velocityFactor,
    required ViewportBuilder viewportBuilder,
  }) : super(
          key: key,
          axisDirection: axisDirection,
          controller: controller,
          physics: physics,
          viewportBuilder: viewportBuilder,
        );

  final double itemExtent;
  final int itemCount;
  final bool loop;
  final double velocityFactor;

  @override
  _InfiniteScrollableState createState() => _InfiniteScrollableState();
}

class _InfiniteScrollableState extends ScrollableState {
  double get itemExtent => (widget as _InfiniteScrollable).itemExtent;
  int get itemCount => (widget as _InfiniteScrollable).itemCount;
  bool get loop => (widget as _InfiniteScrollable).loop;
  double get velocityFactor => (widget as _InfiniteScrollable).velocityFactor;
}

/// Scroll controller for [InfiniteCarousel].
class InfiniteScrollController extends ScrollController {
  /// Scroll controller for [InfiniteCarousel].
  InfiniteScrollController({this.initialItem = 0});

  /// Initial item index for [InfiniteScrollController]. Defaults to 0.
  final int initialItem;

  /// Returns selected Item index. If loop => true, then it returns the modded index value.
  int get selectedItem => _getTrueIndex(
        (this.position as _InfiniteScrollPosition).itemIndex,
        (this.position as _InfiniteScrollPosition).itemCount,
      );

  /// Animate to specific item index.
  Future<void> animateToItem(int itemIndex,
      {Duration duration = _kDefaultDuration,
      Curve curve = _kDefaultCurve}) async {
    if (!hasClients) return;

    await Future.wait<void>([
      for (final position in positions.cast<_InfiniteScrollPosition>())
        position.animateTo(itemIndex * position.itemExtent,
            duration: duration, curve: curve),
    ]);
  }

  /// Jump to specific item index.
  void jumpToItem(int itemIndex) {
    for (final position in positions.cast<_InfiniteScrollPosition>()) {
      position.jumpTo(itemIndex * position.itemExtent);
    }
  }

  /// Animate to next item in viewport.
  Future<void> nextItem(
      {Duration duration = _kDefaultDuration,
      Curve curve = _kDefaultCurve}) async {
    if (!hasClients) return;

    await Future.wait<void>([
      for (final position in positions.cast<_InfiniteScrollPosition>())
        position.animateTo(offset + position.itemExtent,
            duration: duration, curve: curve),
    ]);
  }

  /// Animate to previous item in viewport.
  Future<void> previousItem(
      {Duration duration = _kDefaultDuration,
      Curve curve = _kDefaultCurve}) async {
    if (!hasClients) return;

    await Future.wait<void>([
      for (final position in positions.cast<_InfiniteScrollPosition>())
        position.animateTo(offset - position.itemExtent,
            duration: duration, curve: curve),
    ]);
  }

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return _InfiniteScrollPosition(
      physics: physics,
      context: context,
      initialItem: initialItem,
      oldPosition: oldPosition,
    );
  }
}

/// Metrics for Infinite scroll controller. This is an immutable snapshot of the current values of scroll position.
/// This can directly be accessed by ScrollNotification to currently selected real item index at any time.
class InfiniteExtentMetrics extends FixedScrollMetrics {
  InfiniteExtentMetrics({
    required double? minScrollExtent,
    required double? maxScrollExtent,
    required double? pixels,
    required double? viewportDimension,
    required AxisDirection axisDirection,
    required this.itemIndex,
  }) : super(
          minScrollExtent: minScrollExtent,
          maxScrollExtent: maxScrollExtent,
          pixels: pixels,
          viewportDimension: viewportDimension,
          axisDirection: axisDirection,
        );

  @override
  InfiniteExtentMetrics copyWith({
    double? minScrollExtent,
    double? maxScrollExtent,
    double? pixels,
    double? viewportDimension,
    AxisDirection? axisDirection,
    int? itemIndex,
  }) {
    return InfiniteExtentMetrics(
      minScrollExtent: minScrollExtent ?? this.minScrollExtent,
      maxScrollExtent: maxScrollExtent ?? this.maxScrollExtent,
      pixels: pixels ?? this.pixels,
      viewportDimension: viewportDimension ?? this.viewportDimension,
      axisDirection: axisDirection ?? this.axisDirection,
      itemIndex: itemIndex ?? this.itemIndex,
    );
  }

  /// The scroll view's currently selected item index.
  final int itemIndex;
}

int _getItemFromOffset({
  required double offset,
  required double itemExtent,
  required double minScrollExtent,
  required double maxScrollExtent,
}) {
  return (_clipOffsetToScrollableRange(
              offset, minScrollExtent, maxScrollExtent) /
          itemExtent)
      .round();
}

double _clipOffsetToScrollableRange(
    double offset, double minScrollExtent, double maxScrollExtent) {
  return math.min(math.max(offset, minScrollExtent), maxScrollExtent);
}

/// Get the modded item index from real index.
int _getTrueIndex(int currentIndex, int totalCount) {
  if (currentIndex >= 0) {
    return currentIndex % totalCount;
  }

  return (totalCount + (currentIndex % totalCount)) % totalCount;
}

class _InfiniteScrollPosition extends ScrollPositionWithSingleContext
    implements InfiniteExtentMetrics {
  _InfiniteScrollPosition({
    required ScrollPhysics physics,
    required ScrollContext context,
    required int initialItem,
    bool keepScrollOffset = true,
    ScrollPosition? oldPosition,
    String? debugLabel,
  })  : assert(context is _InfiniteScrollableState),
        super(
          physics: physics,
          context: context,
          initialPixels: _getItemExtentFromScrollContext(context) * initialItem,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        );

  double get itemExtent => _getItemExtentFromScrollContext(context);
  static double _getItemExtentFromScrollContext(ScrollContext context) {
    return (context as _InfiniteScrollableState).itemExtent;
  }

  int get itemCount => _getItemCountFromScrollContext(context);
  static int _getItemCountFromScrollContext(ScrollContext context) {
    return (context as _InfiniteScrollableState).itemCount;
  }

  bool get loop => _getLoopFromScrollContext(context);
  static bool _getLoopFromScrollContext(ScrollContext context) {
    return (context as _InfiniteScrollableState).loop;
  }

  double get velocityFactor => _getVelocityFactorFromScrollContext(context);
  static double _getVelocityFactorFromScrollContext(ScrollContext context) {
    return (context as _InfiniteScrollableState).velocityFactor;
  }

  @override
  double get maxScrollExtent =>
      loop ? super.maxScrollExtent : itemExtent * (itemCount - 1);

  @override
  int get itemIndex {
    return _getItemFromOffset(
      offset: pixels,
      itemExtent: itemExtent,
      minScrollExtent: minScrollExtent,
      maxScrollExtent: maxScrollExtent,
    );
  }

  @override
  InfiniteExtentMetrics copyWith({
    double? minScrollExtent,
    double? maxScrollExtent,
    double? pixels,
    double? viewportDimension,
    AxisDirection? axisDirection,
    int? itemIndex,
  }) {
    return InfiniteExtentMetrics(
      minScrollExtent: minScrollExtent ?? this.minScrollExtent,
      maxScrollExtent: maxScrollExtent ?? this.maxScrollExtent,
      pixels: pixels ?? this.pixels,
      viewportDimension: viewportDimension ?? this.viewportDimension,
      axisDirection: axisDirection ?? this.axisDirection,
      itemIndex: itemIndex ?? this.itemIndex,
    );
  }
}

/// Physics for [InfiniteCarousel].
///
/// Based on Flutter's FixedExtentScrollPhysics. Hence, it always lands on a particular item.
///
/// If loop => false, friction is applied when user tries to go beyond Viewport area.
/// Friction factor is calculated the way its done in BouncingScrollPhycics.
class InfiniteScrollPhysics extends ScrollPhysics {
  const InfiniteScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  InfiniteScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return InfiniteScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) => 0.0;

  /// Increase friction for scrolling in out-of-bound areas.
  double frictionFactor(double overscrollFraction) =>
      0.12 * math.pow(1 - overscrollFraction, 2);

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (position.pixels > position.minScrollExtent &&
        position.pixels < position.maxScrollExtent) {
      return offset;
    }

    final double overscrollPastStart =
        math.max(position.minScrollExtent - position.pixels, 0.0);
    final double overscrollPastEnd =
        math.max(position.pixels - position.maxScrollExtent, 0.0);
    final double overscrollPast =
        math.max(overscrollPastStart, overscrollPastEnd);
    final bool easing = (overscrollPastStart > 0.0 && offset < 0.0) ||
        (overscrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing
        // Apply less resistance when easing the overscroll vs tensioning.
        ? frictionFactor(
            (overscrollPast - offset.abs()) / position.viewportDimension)
        : frictionFactor(overscrollPast / position.viewportDimension);
    final double direction = offset.sign;

    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(
      double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) return absDelta * gamma;
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final _InfiniteScrollPosition metrics = position as _InfiniteScrollPosition;

    // Scenario 1:
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at the scrollable's boundary.
    if ((velocity <= 0.0 && metrics.pixels <= metrics.minScrollExtent) ||
        (velocity >= 0.0 && metrics.pixels >= metrics.maxScrollExtent)) {
      return super.createBallisticSimulation(metrics, velocity);
    }

    // Create a test simulation to see where it would have ballistically fallen
    // naturally without settling onto items.
    final Simulation? testFrictionSimulation = super.createBallisticSimulation(
      metrics,
      velocity * math.min(metrics.velocityFactor + 0.15, 1.0),
    );

    // Scenario 2:
    // If it was going to end up past the scroll extent, defer back to the
    // parent physics' ballistics again which should put us on the scrollable's
    // boundary.
    if (testFrictionSimulation != null &&
        (testFrictionSimulation.x(double.infinity) == metrics.minScrollExtent ||
            testFrictionSimulation.x(double.infinity) ==
                metrics.maxScrollExtent)) {
      return super.createBallisticSimulation(metrics, velocity);
    }

    // From the natural final position, find the nearest item it should have
    // settled to.
    final int settlingItemIndex = _getItemFromOffset(
      offset: testFrictionSimulation?.x(double.infinity) ?? metrics.pixels,
      itemExtent: metrics.itemExtent,
      minScrollExtent: metrics.minScrollExtent,
      maxScrollExtent: metrics.maxScrollExtent,
    );

    final double settlingPixels = settlingItemIndex * metrics.itemExtent;

    // Scenario 3:
    // If there's no velocity and we're already at where we intend to land,
    // do nothing.
    if (velocity.abs() < tolerance.velocity &&
        (settlingPixels - metrics.pixels).abs() < tolerance.distance) {
      return null;
    }

    // Scenario 4:
    // If we're going to end back at the same item because initial velocity
    // is too low to break past it, use a spring simulation to get back.
    if (settlingItemIndex == metrics.itemIndex) {
      return SpringSimulation(
        spring,
        metrics.pixels,
        settlingPixels,
        velocity * metrics.velocityFactor,
        tolerance: tolerance,
      );
    }

    // Scenario 5:
    // Create a new friction simulation except the drag will be tweaked to land
    // exactly on the item closest to the natural stopping point.
    return FrictionSimulation.through(
      metrics.pixels,
      settlingPixels,
      velocity * metrics.velocityFactor,
      tolerance.velocity * metrics.velocityFactor * velocity.sign,
    );
  }
}
