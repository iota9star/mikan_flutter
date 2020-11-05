import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnimatedTapContainer extends ImplicitlyAnimatedWidget {
  AnimatedTapContainer({
    Key key,
    this.childAlignment = Alignment.center,
    this.transformAlignment = Alignment.center,
    Color color,
    Decoration decoration,
    this.foregroundDecoration,
    double width,
    double height,
    BoxConstraints constraints,
    this.margin,
    this.padding,
    transform,
    this.borderRadius = BorderRadius.zero,
    this.onTap,
    this.onTapStart,
    this.onTapEnd,
    this.child,
    Curve curve = Curves.easeInOut,
    Duration duration,
  })  : assert(padding == null || padding.isNonNegative),
        assert(margin == null || margin.isNonNegative),
        assert(decoration == null || decoration.debugAssertIsValid()),
        assert(constraints == null || constraints.debugAssertIsValid()),
        assert(
            color == null || decoration == null,
            'Cannot provide both a color and a decoration\n'
            'The color argument is just a shorthand for "decoration: new BoxDecoration(backgroundColor: color)".'),
        decoration =
            decoration ?? (color != null ? BoxDecoration(color: color) : null),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        transform = transform ?? Matrix4.identity(),
        super(
            key: key,
          curve: curve,
          duration: duration ?? Duration(milliseconds: 200));

  final Widget child;
  final AlignmentGeometry childAlignment;
  final AlignmentGeometry transformAlignment;
  final Decoration decoration;
  final Decoration foregroundDecoration;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Matrix4 transform;
  final BorderRadius borderRadius;
  final VoidCallback onTap;
  final VoidCallback onTapStart;
  final VoidCallback onTapEnd;

  @override
  _AnimatedTapContainerState createState() => _AnimatedTapContainerState();
}

class _AnimatedTapContainerState
    extends AnimatedWidgetBaseState<AnimatedTapContainer> {
  AlignmentGeometryTween _childAlignment;
  AlignmentGeometryTween _transformAlignment;
  DecorationTween _decoration;
  DecorationTween _foregroundDecoration;
  BoxConstraintsTween _constraints;
  EdgeInsetsGeometryTween _margin;
  EdgeInsetsGeometryTween _padding;
  Matrix4Tween _transform;
  BorderRadiusTween _borderRadius;
  DateTime _clickTime;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _childAlignment = visitor(_childAlignment, widget.childAlignment,
            (dynamic value) => AlignmentGeometryTween(begin: value));
    _transformAlignment = visitor(
        _transformAlignment,
        widget.transformAlignment,
            (dynamic value) => AlignmentGeometryTween(begin: value));
    _decoration = visitor(_decoration, widget.decoration,
            (dynamic value) => DecorationTween(begin: value));
    _foregroundDecoration = visitor(
        _foregroundDecoration,
        widget.foregroundDecoration,
            (dynamic value) => DecorationTween(begin: value));
    _constraints = visitor(_constraints, widget.constraints,
            (dynamic value) => BoxConstraintsTween(begin: value));
    _margin = visitor(_margin, widget.margin,
            (dynamic value) => EdgeInsetsGeometryTween(begin: value));
    _padding = visitor(_padding, widget.padding,
            (dynamic value) => EdgeInsetsGeometryTween(begin: value));
    _transform = visitor(_transform, widget.transform,
            (dynamic value) => Matrix4Tween(begin: value));
    _borderRadius = visitor(_borderRadius, widget.borderRadius,
            (dynamic value) => BorderRadiusTween(begin: value));
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: _transformAlignment?.evaluate(animation),
      transform: _transform?.evaluate(animation),
      child: Container(
        child: GestureDetector(
          onTapDown: (_) {
            if (_clickTime != null) return;
            _clickTime = DateTime.now();
            widget.onTapStart?.call();
          },
          onTapCancel: () async {
            await _callTapEnd();
          },
          onTap: () {
            widget.onTap?.call();
          },
          onTapUp: (_) async {
            await _callTapEnd();
          },
          child: widget.child,
        ),
        alignment: _childAlignment?.evaluate(animation),
        decoration: _decoration?.evaluate(animation),
        foregroundDecoration: _foregroundDecoration?.evaluate(animation),
        constraints: _constraints?.evaluate(animation),
        margin: _margin?.evaluate(animation),
        padding: _padding?.evaluate(animation),
      ),
    );
  }

  Future _callTapEnd() async {
    if (widget.onTapEnd == null) return;
    Duration diff = DateTime.now().difference(_clickTime);
    if (diff < widget.duration) {
      await Future.delayed(widget.duration - diff);
    }
    _clickTime = null;
    widget.onTapEnd.call();
  }
}
