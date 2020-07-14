import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
    transform,
    this.borderRadius = BorderRadius.zero,
    this.onTap,
    this.onTapStart,
    this.onTapEnd,
    this.child,
    this.ink = true,
    Curve curve = Curves.easeInOut,
    Duration duration,
  })  : assert(margin == null || margin.isNonNegative),
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
  final bool ink;
  final AlignmentGeometry childAlignment;
  final AlignmentGeometry transformAlignment;
  final Decoration decoration;
  final Decoration foregroundDecoration;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry margin;
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
        child: widget.ink
            ? ClipRRect(
                borderRadius:
                    _borderRadius?.evaluate(animation) ?? BorderRadius.zero,
                child: Material(
                  color: Colors.transparent,
                  child: TapRipple(
                    highlightShape: BoxShape.rectangle,
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
                ),
              )
            : GestureDetector(
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
      ),
    );
  }

  Future _callTapEnd() async {
    Duration diff = DateTime.now().difference(_clickTime);
    if (diff < widget.duration) {
      await Future.delayed(widget.duration - diff);
    }
    _clickTime = null;
    widget.onTapEnd?.call();
  }
}

class TapRipple extends StatefulWidget {
  /// Creates an area of a [Material] that responds to touch.
  ///
  /// Must have an ancestor [Material] widget in which to cause ink reactions.
  ///
  /// The [containedInkWell], [highlightShape], [enableFeedback], and
  /// [excludeFromSemantics] arguments must not be null.
  const TapRipple({
    Key key,
    this.child,
    this.onTap,
    this.onTapUp,
    this.onTapDown,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onHighlightChanged,
    this.onHover,
    this.containedInkWell = true,
    this.highlightShape = BoxShape.rectangle,
    this.radius,
    this.borderRadius,
    this.customBorder,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.splashFactory,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
  })  : assert(containedInkWell != null),
        assert(highlightShape != null),
        assert(enableFeedback != null),
        assert(excludeFromSemantics != null),
        assert(autofocus != null),
        assert(canRequestFocus != null),
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// Called when the user taps this part of the material.
  final GestureTapCallback onTap;

  /// Called when the user taps down this part of the material.
  final GestureTapDownCallback onTapDown;

  final GestureTapUpCallback onTapUp;

  /// Called when the user cancels a tap that was started on this part of the
  /// material.
  final GestureTapCallback onTapCancel;

  /// Called when the user double taps this part of the material.
  final GestureTapCallback onDoubleTap;

  /// Called when the user long-presses on this part of the material.
  final GestureLongPressCallback onLongPress;

  /// Called when this part of the material either becomes highlighted or stops
  /// being highlighted.
  ///
  /// The value passed to the callback is true if this part of the material has
  /// become highlighted and false if this part of the material has stopped
  /// being highlighted.
  ///
  /// If all of [onTap], [onDoubleTap], and [onLongPress] become null while a
  /// gesture is ongoing, then [onTapCancel] will be fired and
  /// [onHighlightChanged] will be fired with the value false _during the
  /// build_. This means, for instance, that in that scenario [State.setState]
  /// cannot be called.
  final ValueChanged<bool> onHighlightChanged;

  /// Called when a pointer enters or exits the ink response area.
  ///
  /// The value passed to the callback is true if a pointer has entered this
  /// part of the material and false if a pointer has exited this part of the
  /// material.
  final ValueChanged<bool> onHover;

  /// Whether this ink response should be clipped its bounds.
  ///
  /// This flag also controls whether the splash migrates to the center of the
  /// [TapRipple] or not. If [containedInkWell] is true, the splash remains
  /// centered around the tap location. If it is false, the splash migrates to
  /// the center of the [TapRipple] as it grows.
  ///
  /// See also:
  ///
  ///  * [highlightShape], the shape of the focus, hover, and pressed
  ///    highlights.
  ///  * [borderRadius], which controls the corners when the box is a rectangle.
  ///  * [getRectCallback], which controls the size and position of the box when
  ///    it is a rectangle.
  final bool containedInkWell;

  /// The shape (e.g., circle, rectangle) to use for the highlight drawn around
  /// this part of the material when pressed, hovered over, or focused.
  ///
  /// The same shape is used for the pressed highlight (see [highlightColor]),
  /// the focus highlight (see [focusColor]), and the hover highlight (see
  /// [hoverColor]).
  ///
  /// If the shape is [BoxShape.circle], then the highlight is centered on the
  /// [TapRipple]. If the shape is [BoxShape.rectangle], then the highlight
  /// fills the [TapRipple], or the rectangle provided by [getRectCallback] if
  /// the callback is specified.
  ///
  /// See also:
  ///
  ///  * [containedInkWell], which controls clipping behavior.
  ///  * [borderRadius], which controls the corners when the box is a rectangle.
  ///  * [highlightColor], the color of the highlight.
  ///  * [getRectCallback], which controls the size and position of the box when
  ///    it is a rectangle.
  final BoxShape highlightShape;

  /// The radius of the ink splash.
  ///
  /// Splashes grow up to this size. By default, this size is determined from
  /// the size of the rectangle provided by [getRectCallback], or the size of
  /// the [TapRipple] itself.
  ///
  /// See also:
  ///
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final double radius;

  /// The clipping radius of the containing rect. This is effective only if
  /// [customBorder] is null.
  ///
  /// If this is null, it is interpreted as [BorderRadius.zero].
  final BorderRadius borderRadius;

  /// The custom clip border which overrides [borderRadius].
  final ShapeBorder customBorder;

  /// The color of the ink response when the parent widget is focused. If this
  /// property is null then the focus color of the theme,
  /// [ThemeData.focusColor], will be used.
  ///
  /// See also:
  ///
  ///  * [highlightShape], the shape of the focus, hover, and pressed
  ///    highlights.
  ///  * [hoverColor], the color of the hover highlight.
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final Color focusColor;

  /// The color of the ink response when a pointer is hovering over it. If this
  /// property is null then the hover color of the theme,
  /// [ThemeData.hoverColor], will be used.
  ///
  /// See also:
  ///
  ///  * [highlightShape], the shape of the focus, hover, and pressed
  ///    highlights.
  ///  * [highlightColor], the color of the pressed highlight.
  ///  * [focusColor], the color of the focus highlight.
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final Color hoverColor;

  /// The highlight color of the ink response when pressed. If this property is
  /// null then the highlight color of the theme, [ThemeData.highlightColor],
  /// will be used.
  ///
  /// See also:
  ///
  ///  * [hoverColor], the color of the hover highlight.
  ///  * [focusColor], the color of the focus highlight.
  ///  * [highlightShape], the shape of the focus, hover, and pressed
  ///    highlights.
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final Color highlightColor;

  /// The splash color of the ink response. If this property is null then the
  /// splash color of the theme, [ThemeData.splashColor], will be used.
  ///
  /// See also:
  ///
  ///  * [splashFactory], which defines the appearance of the splash.
  ///  * [radius], the (maximum) size of the ink splash.
  ///  * [highlightColor], the color of the highlight.
  final Color splashColor;

  /// Defines the appearance of the splash.
  ///
  /// Defaults to the value of the theme's splash factory: [ThemeData.splashFactory].
  ///
  /// See also:
  ///
  ///  * [radius], the (maximum) size of the ink splash.
  ///  * [splashColor], the color of the splash.
  ///  * [highlightColor], the color of the highlight.
  ///  * [InkSplash.splashFactory], which defines the default splash.
  ///  * [InkRipple.splashFactory], which defines a splash that spreads out
  ///    more aggressively than the default.
  final InteractiveInkFeatureFactory splashFactory;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool enableFeedback;

  /// Whether to exclude the gestures introduced by this widget from the
  /// semantics tree.
  ///
  /// For example, a long-press gesture for showing a tooltip is usually
  /// excluded because the tooltip itself is included in the semantics
  /// tree directly and so having a gesture to show it would result in
  /// duplication of information.
  final bool excludeFromSemantics;

  /// Handler called when the focus changes.
  ///
  /// Called with true if this widget's node gains focus, and false if it loses
  /// focus.
  final ValueChanged<bool> onFocusChange;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode focusNode;

  /// {@template flutter.widgets.Focus.canRequestFocus}
  final bool canRequestFocus;

  /// The rectangle to use for the highlight effect and for clipping
  /// the splash effects if [containedInkWell] is true.
  ///
  /// This method is intended to be overridden by descendants that
  /// specialize [TapRipple] for unusual cases. For example,
  /// [TableRowInkWell] implements this method to return the rectangle
  /// corresponding to the row that the widget is in.
  ///
  /// The default behavior returns null, which is equivalent to
  /// returning the referenceBox argument's bounding box (though
  /// slightly more efficient).
  RectCallback getRectCallback(RenderBox referenceBox) => null;

  /// Asserts that the given context satisfies the prerequisites for
  /// this class.
  ///
  /// This method is intended to be overridden by descendants that
  /// specialize [TapRipple] for unusual cases. For example,
  /// [TableRowInkWell] implements this method to verify that the widget is
  /// in a table.
  @mustCallSuper
  bool debugCheckContext(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasDirectionality(context));
    return true;
  }

  @override
  _TapRippleState createState() => _TapRippleState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final List<String> gestures = <String>[
      if (onTap != null) 'tap',
      if (onDoubleTap != null) 'double tap',
      if (onLongPress != null) 'long press',
      if (onTapDown != null) 'tap down',
      if (onTapCancel != null) 'tap cancel',
    ];
    properties
        .add(IterableProperty<String>('gestures', gestures, ifEmpty: '<none>'));
    properties.add(DiagnosticsProperty<bool>(
        'containedInkWell', containedInkWell,
        level: DiagnosticLevel.fine));
    properties.add(DiagnosticsProperty<BoxShape>(
      'highlightShape',
      highlightShape,
      description: '${containedInkWell ? "clipped to " : ""}$highlightShape',
      showName: false,
    ));
  }
}

/// Used to index the allocated highlights for the different types of highlights
/// in [_TapRippleState].
enum _HighlightType {
  pressed,
  hover,
  focus,
}

class _TapRippleState extends State<TapRipple>
    with AutomaticKeepAliveClientMixin<TapRipple> {
  Set<InteractiveInkFeature> _splashes;
  InteractiveInkFeature _currentSplash;
  bool _hovering = false;
  final Map<_HighlightType, InkHighlight> _highlights =
      <_HighlightType, InkHighlight>{};
  Map<LocalKey, ActionFactory> _actionMap;

  bool get highlightsExist => _highlights.values
      .where((InkHighlight highlight) => highlight != null)
      .isNotEmpty;

  void _handleAction(FocusNode node, Intent intent) {
    _startSplash(context: node.context);
    _handleTap(node.context);
  }

  Action _createAction() {
    return CallbackAction(
      ActivateAction.key,
      onInvoke: _handleAction,
    );
  }

  @override
  void initState() {
    super.initState();
    _actionMap = <LocalKey, ActionFactory>{
      SelectAction.key: _createAction,
      if (!kIsWeb) ActivateAction.key: _createAction,
    };
    FocusManager.instance
        .addHighlightModeListener(_handleFocusHighlightModeChange);
  }

  @override
  void didUpdateWidget(TapRipple oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isWidgetEnabled(widget) != _isWidgetEnabled(oldWidget)) {
      _handleHoverChange(_hovering);
      _updateFocusHighlights();
    }
  }

  @override
  void dispose() {
    FocusManager.instance
        .removeHighlightModeListener(_handleFocusHighlightModeChange);
    super.dispose();
  }

  @override
  bool get wantKeepAlive =>
      highlightsExist || (_splashes != null && _splashes.isNotEmpty);

  Color getHighlightColorForType(_HighlightType type) {
    switch (type) {
      case _HighlightType.pressed:
        return widget.highlightColor ?? Theme.of(context).highlightColor;
      case _HighlightType.focus:
        return widget.focusColor ?? Theme.of(context).focusColor;
      case _HighlightType.hover:
        return widget.hoverColor ?? Theme.of(context).hoverColor;
    }
    assert(false, 'Unhandled $_HighlightType $type');
    return null;
  }

  Duration getFadeDurationForType(_HighlightType type) {
    switch (type) {
      case _HighlightType.pressed:
        return const Duration(milliseconds: 200);
      case _HighlightType.hover:
      case _HighlightType.focus:
        return const Duration(milliseconds: 50);
    }
    assert(false, 'Unhandled $_HighlightType $type');
    return null;
  }

  void updateHighlight(_HighlightType type, {@required bool value}) {
    final InkHighlight highlight = _highlights[type];
    void handleInkRemoval() {
      assert(_highlights[type] != null);
      _highlights[type] = null;
      updateKeepAlive();
    }

    if (value == (highlight != null && highlight.active)) return;
    if (value) {
      if (highlight == null) {
        final RenderBox referenceBox = context.findRenderObject();
        _highlights[type] = InkHighlight(
          controller: Material.of(context),
          referenceBox: referenceBox,
          color: getHighlightColorForType(type),
          shape: widget.highlightShape,
          borderRadius: widget.borderRadius,
          customBorder: widget.customBorder,
          rectCallback: widget.getRectCallback(referenceBox),
          onRemoved: handleInkRemoval,
          textDirection: Directionality.of(context),
          fadeDuration: getFadeDurationForType(type),
        );
        updateKeepAlive();
      } else {
        highlight.activate();
      }
    } else {
      highlight.deactivate();
    }
    assert(value == (_highlights[type] != null && _highlights[type].active));

    switch (type) {
      case _HighlightType.pressed:
        if (widget.onHighlightChanged != null) widget.onHighlightChanged(value);
        break;
      case _HighlightType.hover:
        if (widget.onHover != null) widget.onHover(value);
        break;
      case _HighlightType.focus:
        break;
    }
  }

  InteractiveInkFeature _createInkFeature(Offset globalPosition) {
    final MaterialInkController inkController = Material.of(context);
    final RenderBox referenceBox = context.findRenderObject();
    final Offset position = referenceBox.globalToLocal(globalPosition);
    final Color color = widget.splashColor ?? Theme.of(context).splashColor;
    final RectCallback rectCallback =
        widget.containedInkWell ? widget.getRectCallback(referenceBox) : null;
    final BorderRadius borderRadius = widget.borderRadius;
    final ShapeBorder customBorder = widget.customBorder;

    InteractiveInkFeature splash;
    void onRemoved() {
      if (_splashes != null) {
        assert(_splashes.contains(splash));
        _splashes.remove(splash);
        if (_currentSplash == splash) _currentSplash = null;
        updateKeepAlive();
      } // else we're probably in deactivate()
    }

    splash = (widget.splashFactory ?? Theme.of(context).splashFactory).create(
      controller: inkController,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: widget.containedInkWell,
      rectCallback: rectCallback,
      radius: widget.radius,
      borderRadius: borderRadius,
      customBorder: customBorder,
      onRemoved: onRemoved,
      textDirection: Directionality.of(context),
    );

    return splash;
  }

  void _handleFocusHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted) {
      return;
    }
    setState(() {
      _updateFocusHighlights();
    });
  }

  void _updateFocusHighlights() {
    bool showFocus;
    switch (FocusManager.instance.highlightMode) {
      case FocusHighlightMode.touch:
        showFocus = false;
        break;
      case FocusHighlightMode.traditional:
        showFocus = enabled && _hasFocus;
        break;
    }
    updateHighlight(_HighlightType.focus, value: showFocus);
  }

  bool _hasFocus = false;

  void _handleFocusUpdate(bool hasFocus) {
    _hasFocus = hasFocus;
    _updateFocusHighlights();
    if (widget.onFocusChange != null) {
      widget.onFocusChange(hasFocus);
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _startSplash(details: details);
    if (widget.onTapDown != null) {
      widget.onTapDown(details);
    }
  }

  void _startSplash({TapDownDetails details, BuildContext context}) {
    assert(details != null || context != null);

    Offset globalPosition;
    if (context != null) {
      final RenderBox referenceBox = context.findRenderObject();
      assert(referenceBox.hasSize,
          'InkResponse must be done with layout before starting a splash.');
      globalPosition =
          referenceBox.localToGlobal(referenceBox.paintBounds.center);
    } else {
      globalPosition = details.globalPosition;
    }
    final InteractiveInkFeature splash = _createInkFeature(globalPosition);
    _splashes ??= HashSet<InteractiveInkFeature>();
    _splashes.add(splash);
    _currentSplash = splash;
    updateKeepAlive();
    updateHighlight(_HighlightType.pressed, value: true);
  }

  void _handleTap(BuildContext context) {
    _currentSplash?.confirm();
    _currentSplash = null;
    updateHighlight(_HighlightType.pressed, value: false);
    if (widget.onTap != null) {
      if (widget.enableFeedback) {
        Feedback.forTap(context);
      }
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    _currentSplash?.cancel();
    _currentSplash = null;
    if (widget.onTapCancel != null) {
      widget.onTapCancel();
    }
    updateHighlight(_HighlightType.pressed, value: false);
  }

  void _handleDoubleTap() {
    _currentSplash?.confirm();
    _currentSplash = null;
    if (widget.onDoubleTap != null) {
      widget.onDoubleTap();
    }
  }

  void _handleLongPress(BuildContext context) {
    _currentSplash?.confirm();
    _currentSplash = null;
    if (widget.onLongPress != null) {
      if (widget.enableFeedback) {
        Feedback.forLongPress(context);
      }
      widget.onLongPress();
    }
  }

  @override
  void deactivate() {
    if (_splashes != null) {
      final Set<InteractiveInkFeature> splashes = _splashes;
      _splashes = null;
      for (InteractiveInkFeature splash in splashes) {
        splash.dispose();
      }
      _currentSplash = null;
    }
    assert(_currentSplash == null);
    for (_HighlightType highlight in _highlights.keys) {
      _highlights[highlight]?.dispose();
      _highlights[highlight] = null;
    }
    super.deactivate();
  }

  bool _isWidgetEnabled(TapRipple widget) {
    return widget.onTap != null ||
        widget.onDoubleTap != null ||
        widget.onLongPress != null;
  }

  bool get enabled => _isWidgetEnabled(widget);

  void _handleMouseEnter(PointerEnterEvent event) => _handleHoverChange(true);

  void _handleMouseExit(PointerExitEvent event) => _handleHoverChange(false);

  void _handleHoverChange(bool hovering) {
    if (_hovering != hovering) {
      _hovering = hovering;
      updateHighlight(_HighlightType.hover, value: enabled && _hovering);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.debugCheckContext(context));
    super.build(context); // See AutomaticKeepAliveClientMixin.
    for (_HighlightType type in _highlights.keys) {
      _highlights[type]?.color = getHighlightColorForType(type);
    }
    _currentSplash?.color = widget.splashColor ?? Theme.of(context).splashColor;
    final bool canRequestFocus = enabled && widget.canRequestFocus;
    return Actions(
      actions: _actionMap,
      child: Focus(
        focusNode: widget.focusNode,
        canRequestFocus: canRequestFocus,
        onFocusChange: _handleFocusUpdate,
        autofocus: widget.autofocus,
        child: MouseRegion(
          onEnter: enabled ? _handleMouseEnter : null,
          onExit: enabled ? _handleMouseExit : null,
          child: GestureDetector(
            onTapDown: enabled ? _handleTapDown : null,
            onTapUp: enabled ? widget.onTapUp : null,
            onTap: enabled ? () => _handleTap(context) : null,
            onTapCancel: enabled ? _handleTapCancel : null,
            onDoubleTap: widget.onDoubleTap != null ? _handleDoubleTap : null,
            onLongPress: widget.onLongPress != null
                ? () => _handleLongPress(context)
                : null,
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: widget.excludeFromSemantics,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
