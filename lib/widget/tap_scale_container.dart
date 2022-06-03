library flutter_scale_tap;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:sprung/sprung.dart';

const _kDuration = Duration(milliseconds: 200);
final _kSpringCurve = Sprung();

class TapScaleContainer extends StatefulWidget {
  final Function()? onTap;
  final GestureLongPressCallback? onLongPress;
  final Widget? child;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry transformAlignment;
  final double? width;
  final double? height;
  final Clip clipBehavior;
  final Curve? curve;

  const TapScaleContainer({
    Key? key,
    this.onTap,
    this.onLongPress,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.margin,
    this.transformAlignment = Alignment.center,
    this.child,
    this.clipBehavior = Clip.none,
    this.constraints,
    this.curve,
  }) : super(key: key);

  @override
  _TapScaleContainerState createState() => _TapScaleContainerState();
}

class _TapScaleContainerState extends State<TapScaleContainer> {
  late DateTime _clickTime;

  Matrix4 _transform = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _tapStart(),
      onTapCancel: () => _tapEnd(),
      onTapUp: (_) => _tapEnd(),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: _kDuration,
        transform: _transform,
        curve: widget.curve ?? _kSpringCurve,
        alignment: widget.alignment,
        padding: widget.padding,
        color: widget.color,
        decoration: widget.decoration,
        width: widget.width,
        height: widget.height,
        foregroundDecoration: widget.foregroundDecoration,
        constraints: widget.constraints,
        margin: widget.margin,
        transformAlignment: widget.transformAlignment,
        clipBehavior: widget.clipBehavior,
        child: widget.child,
      ),
    );
  }

  _tapEnd() async {
    final Duration diff = DateTime.now().difference(_clickTime);
    if (diff < _kDuration) {
      await Future.delayed(_kDuration - diff);
    }
    setSafeState(() {
      _transform = Matrix4.identity();
    });
  }

  _tapStart() {
    _clickTime = DateTime.now();
    setSafeState(() {
      _transform = Matrix4.diagonal3Values(0.92, 0.92, 1);
    });
  }
}
