///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-20 16:36
///
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.activeColor,
    this.dragStartBehavior = DragStartBehavior.start,
    this.trackWidth = 50.0,
    this.trackHeight = 28.0,
  })  : assert(value != null),
        assert(dragStartBehavior != null),
        super(key: key);

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final DragStartBehavior dragStartBehavior;

  final double trackWidth;
  final double trackHeight;

  @override
  _CustomSwitchState createState() => _CustomSwitchState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty(
      'value',
      value: value,
      ifTrue: 'on',
      ifFalse: 'off',
      showName: true,
    ));
    properties.add(ObjectFlagProperty<ValueChanged<bool>>(
      'onChanged',
      onChanged,
      ifNull: 'disabled',
    ));
  }
}

class _CustomSwitchState extends State<CustomSwitch>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity:
          widget.onChanged == null ? _kCupertinoSwitchDisabledOpacity : 1.0,
      child: _CustomSwitchRenderObjectWidget(
        value: widget.value,
        activeColor: CupertinoDynamicColor.resolve(
          widget.activeColor ?? CupertinoColors.systemGreen,
          context,
        ),
        onChanged: widget.onChanged,
        vsync: this,
        dragStartBehavior: widget.dragStartBehavior,
        trackWidth: widget.trackWidth,
        trackHeight: widget.trackHeight,
      ),
    );
  }
}

class _CustomSwitchRenderObjectWidget extends LeafRenderObjectWidget {
  const _CustomSwitchRenderObjectWidget({
    Key key,
    this.value,
    this.activeColor,
    this.onChanged,
    this.vsync,
    this.dragStartBehavior = DragStartBehavior.start,
    this.trackWidth,
    this.trackHeight,
  }) : super(key: key);

  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;
  final TickerProvider vsync;
  final DragStartBehavior dragStartBehavior;

  final double trackWidth;
  final double trackHeight;

  @override
  _RenderCustomSwitch createRenderObject(BuildContext context) {
    return _RenderCustomSwitch(
      value: value,
      activeColor: activeColor,
      trackColor: CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemFill, context),
      onChanged: onChanged,
      textDirection: Directionality.of(context),
      vsync: vsync,
      dragStartBehavior: dragStartBehavior,
      trackWidth: trackWidth,
      trackHeight: trackHeight,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderCustomSwitch renderObject) {
    renderObject
      ..value = value
      ..activeColor = activeColor
      ..trackColor = CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemFill, context)
      ..onChanged = onChanged
      ..textDirection = Directionality.of(context)
      ..vsync = vsync
      ..dragStartBehavior = dragStartBehavior
      ..trackWidth = trackWidth
      ..trackHeight = trackHeight;
  }
}

const double _kCupertinoSwitchDisabledOpacity = 0.5;

const Duration _kReactionDuration = Duration(milliseconds: 300);
const Duration _kToggleDuration = Duration(milliseconds: 200);

class _RenderCustomSwitch extends RenderConstrainedBox {
  _RenderCustomSwitch({
    @required bool value,
    @required Color activeColor,
    @required Color trackColor,
    ValueChanged<bool> onChanged,
    @required TextDirection textDirection,
    @required TickerProvider vsync,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    double trackWidth,
    double trackHeight,
  })  : assert(value != null),
        assert(activeColor != null),
        assert(vsync != null),
        _value = value,
        _activeColor = activeColor,
        _trackColor = trackColor,
        _onChanged = onChanged,
        _textDirection = textDirection,
        _vsync = vsync,
        _trackWidth = trackWidth,
        _trackHeight = trackHeight,
        super(
          additionalConstraints: BoxConstraints.tightFor(
            width: trackWidth,
            height: trackWidth,
          ),
        ) {
    _tap = TapGestureRecognizer()
      ..onTapDown = _handleTapDown
      ..onTap = _handleTap
      ..onTapUp = _handleTapUp
      ..onTapCancel = _handleTapCancel;
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..dragStartBehavior = dragStartBehavior;
    _positionController = AnimationController(
      duration: _kToggleDuration,
      value: value ? 1.0 : 0.0,
      vsync: vsync,
    );
    _position = CurvedAnimation(
      parent: _positionController,
      curve: Curves.linear,
    )
      ..addListener(markNeedsPaint)
      ..addStatusListener(_handlePositionStateChanged);
    _reactionController = AnimationController(
      duration: _kReactionDuration,
      vsync: vsync,
    );
    _reaction = CurvedAnimation(
      parent: _reactionController,
      curve: Curves.ease,
    )..addListener(markNeedsPaint);
  }

  double _trackWidth;

  double get trackWidth => _trackWidth;

  set trackWidth(double value) {
    assert(value != null);
    if (value == _trackWidth) {
      return;
    }
    _trackWidth = value;
    markNeedsPaint();
  }

  double _trackHeight;

  double get trackHeight => _trackHeight;

  set trackHeight(double value) {
    assert(value != null);
    if (value == _trackHeight) {
      return;
    }
    _trackHeight = value;
    markNeedsPaint();
  }

  double get _kTrackWidth => trackWidth;

  double get _kTrackHeight => trackHeight;

  double get _kTrackRadius => trackHeight / 2.0;

  double get _kTrackInnerStart => _kTrackHeight / 1.4;

  double get _kTrackInnerEnd => _kTrackWidth - _kTrackInnerStart;

  double get _kTrackInnerLength => _kTrackInnerEnd - _kTrackInnerStart;

  AnimationController _positionController;
  CurvedAnimation _position;

  AnimationController _reactionController;
  Animation<double> _reaction;

  bool get value => _value;
  bool _value;

  set value(bool value) {
    assert(value != null);
    if (value == _value) {
      return;
    }
    _value = value;
    markNeedsSemanticsUpdate();
    _position
      ..curve = Curves.ease
      ..reverseCurve = Curves.ease.flipped;
    if (value) {
      _positionController.forward();
    } else {
      _positionController.reverse();
    }
  }

  TickerProvider get vsync => _vsync;
  TickerProvider _vsync;

  set vsync(TickerProvider value) {
    assert(value != null);
    if (value == _vsync) {
      return;
    }
    _vsync = value;
    _positionController.resync(vsync);
    _reactionController.resync(vsync);
  }

  Color get activeColor => _activeColor;
  Color _activeColor;

  set activeColor(Color value) {
    assert(value != null);
    if (value == _activeColor) {
      return;
    }
    _activeColor = value;
    markNeedsPaint();
  }

  Color get trackColor => _trackColor;
  Color _trackColor;

  set trackColor(Color value) {
    assert(value != null);
    if (value == _trackColor) {
      return;
    }
    _trackColor = value;
    markNeedsPaint();
  }

  ValueChanged<bool> get onChanged => _onChanged;
  ValueChanged<bool> _onChanged;

  set onChanged(ValueChanged<bool> value) {
    if (value == _onChanged) {
      return;
    }
    final bool wasInteractive = isInteractive;
    _onChanged = value;
    if (wasInteractive != isInteractive) {
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    assert(value != null);
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    markNeedsPaint();
  }

  DragStartBehavior get dragStartBehavior => _drag.dragStartBehavior;

  set dragStartBehavior(DragStartBehavior value) {
    assert(value != null);
    if (_drag.dragStartBehavior == value) {
      return;
    }
    _drag.dragStartBehavior = value;
  }

  bool get isInteractive => onChanged != null;

  TapGestureRecognizer _tap;
  HorizontalDragGestureRecognizer _drag;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (value) {
      _positionController.forward();
    } else {
      _positionController.reverse();
    }
    if (isInteractive) {
      switch (_reactionController.status) {
        case AnimationStatus.forward:
          _reactionController.forward();
          break;
        case AnimationStatus.reverse:
          _reactionController.reverse();
          break;
        case AnimationStatus.dismissed:
        case AnimationStatus.completed:
          // nothing to do
          break;
      }
    }
  }

  @override
  void detach() {
    _positionController.stop();
    _reactionController.stop();
    super.detach();
  }

  void _handlePositionStateChanged(AnimationStatus status) {
    if (isInteractive) {
      if (status == AnimationStatus.completed && !_value) {
        onChanged(true);
      } else if (status == AnimationStatus.dismissed && _value) {
        onChanged(false);
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (isInteractive) {
      _reactionController.forward();
    }
  }

  void _handleTap() {
    if (isInteractive) {
      onChanged(!_value);
      _emitVibration();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (isInteractive) {
      _reactionController.reverse();
    }
  }

  void _handleTapCancel() {
    if (isInteractive) {
      _reactionController.reverse();
    }
  }

  void _handleDragStart(DragStartDetails details) {
    if (isInteractive) {
      _reactionController.forward();
      _emitVibration();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (isInteractive) {
      _position
        ..curve = null
        ..reverseCurve = null;
      final double delta = details.primaryDelta / _kTrackInnerLength;
      switch (textDirection) {
        case TextDirection.rtl:
          _positionController.value -= delta;
          break;
        case TextDirection.ltr:
          _positionController.value += delta;
          break;
      }
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_position.value >= 0.5) {
      _positionController.forward();
    } else {
      _positionController.reverse();
    }
    _reactionController.reverse();
  }

  void _emitVibration() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        HapticFeedback.lightImpact();
        break;
      case TargetPlatform.fuchsia:
      case TargetPlatform.android:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        break;
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent && isInteractive) {
      _drag.addPointer(event);
      _tap.addPointer(event);
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    if (isInteractive) {
      config.onTap = _handleTap;
    }

    config.isEnabled = isInteractive;
    config.isToggled = _value;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    final double currentValue = _position.value;
    final double currentReactionValue = _reaction.value;

    double visualPosition;
    switch (textDirection) {
      case TextDirection.rtl:
        visualPosition = 1.0 - currentValue;
        break;
      case TextDirection.ltr:
        visualPosition = currentValue;
        break;
    }

    final Paint paint = Paint()
      ..color = Color.lerp(trackColor, activeColor, currentValue);

    final Rect trackRect = Rect.fromLTWH(
      offset.dx + (size.width - trackWidth) / 2.0,
      offset.dy + (size.height - trackHeight) / 2.0,
      trackWidth,
      trackHeight,
    );
    final RRect trackRRect = RRect.fromRectAndRadius(
      trackRect,
      Radius.circular(_kTrackRadius),
    );
    canvas.drawRRect(trackRRect, paint);

    final double currentThumbExtension =
        CupertinoThumbPainter.extension * currentReactionValue;
    final double thumbLeft = lerpDouble(
      trackRect.left + _kTrackInnerStart - CupertinoThumbPainter.radius,
      trackRect.left +
          _kTrackInnerEnd -
          CupertinoThumbPainter.radius / 1.5 -
          currentThumbExtension,
      visualPosition,
    );
    final double thumbRight = lerpDouble(
      trackRect.left +
          _kTrackInnerStart +
          CupertinoThumbPainter.radius / 1.5 +
          currentThumbExtension,
      trackRect.left + _kTrackInnerEnd + CupertinoThumbPainter.radius,
      visualPosition,
    );
    final double thumbCenterY = offset.dy + size.height / 2.0;
    final Rect thumbBounds = Rect.fromLTRB(
      thumbLeft,
      thumbCenterY - CupertinoThumbPainter.radius / 1.5,
      thumbRight,
      thumbCenterY + CupertinoThumbPainter.radius / 1.5,
    );

    context.pushClipRRect(
      needsCompositing,
      Offset.zero,
      thumbBounds,
      trackRRect,
      (PaintingContext innerContext, Offset offset) {
        const CupertinoThumbPainter.switchThumb()
            .paint(innerContext.canvas, thumbBounds);
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(FlagProperty(
      'value',
      value: value,
      ifTrue: 'checked',
      ifFalse: 'unchecked',
      showName: true,
    ));
    description.add(FlagProperty(
      'isInteractive',
      value: isInteractive,
      ifTrue: 'enabled',
      ifFalse: 'disabled',
      showName: true,
      defaultValue: true,
    ));
  }
}
