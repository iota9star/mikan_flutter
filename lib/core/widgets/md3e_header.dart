import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';

/// Size for the expressive loading indicator.
const double _kExpressiveLoadingIndicatorSize = 48;

/// Md3e header based on MaterialHeader with ExpressiveLoadingIndicator.
class Md3eHeader extends Header {
  const Md3eHeader({
    this.key,
    super.triggerOffset = 100,
    super.clamping = true,
    super.position,
    super.processedDuration = const Duration(milliseconds: 200),
    super.spring,
    super.springRebound = false,
    SpringBuilder? readySpringBuilder,
    FrictionFactor? frictionFactor,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    super.triggerWhenRelease,
    super.maxOverOffset,
    this.noMoreIcon,
  }) : super(
         readySpringBuilder: readySpringBuilder ?? kMaterialSpringBuilder,
         frictionFactor: frictionFactor ?? kMaterialFrictionFactor,
         horizontalFrictionFactor: frictionFactor ?? kMaterialHorizontalFrictionFactor,
       );

  final Key? key;

  /// Icon when [IndicatorResult.noMore].
  final Widget? noMoreIcon;

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return _Md3eIndicator(
      key: key,
      state: state,
      disappearDuration: processedDuration,
      reverse: state.reverse,
      noMoreIcon: noMoreIcon,
    );
  }
}

/// Md3e indicator based on MaterialIndicator with ExpressiveLoadingIndicator.
class _Md3eIndicator extends StatefulWidget {
  const _Md3eIndicator({
    super.key,
    required this.state,
    required this.disappearDuration,
    required this.reverse,
    this.noMoreIcon,
  });

  final IndicatorState state;
  final Duration disappearDuration;
  final bool reverse;
  final Widget? noMoreIcon;

  @override
  State<_Md3eIndicator> createState() => _Md3eIndicatorState();
}

class _Md3eIndicatorState extends State<_Md3eIndicator> {
  IndicatorMode get _mode => widget.state.mode;
  IndicatorResult get _result => widget.state.result;
  Axis get _axis => widget.state.axis;
  double get _offset => widget.state.offset;
  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  Widget _buildIndicator() {
    if (_offset <= 0) {
      return const SizedBox();
    }
    return Container(
      alignment: _axis == Axis.vertical
          ? (widget.reverse ? Alignment.topCenter : Alignment.bottomCenter)
          : (widget.reverse ? Alignment.centerLeft : Alignment.centerRight),
      height: _axis == Axis.vertical ? _actualTriggerOffset : double.infinity,
      width: _axis == Axis.horizontal ? _actualTriggerOffset : double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedScale(
            duration: widget.disappearDuration,
            scale: _mode == IndicatorMode.processed || _mode == IndicatorMode.done ? 0 : 1,
            child: const ExpressiveLoadingIndicator(),
          ),
          if (_mode == IndicatorMode.inactive && _result == IndicatorResult.noMore)
            widget.noMoreIcon ?? const Icon(Icons.inbox_outlined),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double offset = _offset;
    if (widget.state.indicator.infiniteOffset != null &&
        widget.state.indicator.position == IndicatorPosition.locator &&
        (_mode != IndicatorMode.inactive || _result == IndicatorResult.noMore)) {
      offset = _actualTriggerOffset;
    }
    final padding = math.max(_offset - _kExpressiveLoadingIndicatorSize, 0) / 2;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: _axis == Axis.vertical ? double.infinity : offset,
          height: _axis == Axis.horizontal ? double.infinity : offset,
        ),
        Positioned(
          top: _axis == Axis.vertical
              ? widget.reverse
                    ? padding
                    : null
              : 0,
          bottom: _axis == Axis.vertical
              ? widget.reverse
                    ? null
                    : padding
              : 0,
          left: _axis == Axis.horizontal
              ? widget.reverse
                    ? padding
                    : null
              : 0,
          right: _axis == Axis.horizontal
              ? widget.reverse
                    ? null
                    : padding
              : 0,
          child: Center(child: _buildIndicator()),
        ),
      ],
    );
  }
}
