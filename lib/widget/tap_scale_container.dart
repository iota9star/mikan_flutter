library flutter_scale_tap;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sprung/sprung.dart';

const _kDuration = Duration(
  milliseconds: 200,
);
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

  TapScaleContainer({
    Key? key,
    this.onTap,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    this.margin,
    this.transformAlignment = Alignment.center,
    this.child,
    this.clipBehavior = Clip.none,
    this.onLongPress,
  })  : assert(margin == null || margin.isNonNegative),
        assert(padding == null || padding.isNonNegative),
        assert(decoration == null || decoration.debugAssertIsValid()),
        assert(constraints == null || constraints.debugAssertIsValid()),
        assert(decoration != null || clipBehavior == Clip.none),
        assert(
          color == null || decoration == null,
          'Cannot provide both a color and a decoration\n'
          'To provide both, use "decoration: BoxDecoration(color: color)".',
        ),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        super(key: key);
  final Clip clipBehavior;

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
        curve: _kSpringCurve,
        alignment: widget.alignment,
        padding: widget.padding,
        color: widget.color,
        decoration: widget.decoration,
        // foregroundDecoration: widget.foregroundDecoration,
        constraints: widget.constraints,
        margin: widget.margin,
        transformAlignment: widget.transformAlignment,
      ),
    );
  }

  _tapEnd() async {
    Duration diff = DateTime.now().difference(_clickTime);
    if (diff < _kDuration) {
      await Future.delayed(_kDuration - diff);
    }
    setState(() {
      this._transform = Matrix4.identity();
    });
  }

  _tapStart() {
    _clickTime = DateTime.now();
    setState(() {
      _transform = Matrix4.diagonal3Values(0.9, 0.9, 1);
    });
  }
}
