import 'package:flutter/material.dart';

class RippleTap extends StatelessWidget {
  const RippleTap({
    super.key,
    required this.child,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.type = MaterialType.canvas,
    this.elevation = 0.0,
    this.color = Colors.transparent,
    this.shadowColor,
    this.surfaceTintColor,
    this.textStyle,
    this.borderRadius,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.antiAlias,
    this.animationDuration = kThemeChangeDuration,
  });

  final Widget child;

  /// Called when the user taps this part of the material.
  final GestureTapCallback? onTap;

  /// Called when the user taps down this part of the material.
  final GestureTapDownCallback? onTapDown;

  /// Called when the user releases a tap that was started on this part of the
  /// material. [onTap] is called immediately after.
  final GestureTapUpCallback? onTapUp;

  /// Called when the user cancels a tap that was started on this part of the
  /// material.
  final GestureTapCallback? onTapCancel;

  /// Called when the user double taps this part of the material.
  final GestureTapCallback? onDoubleTap;

  /// Called when the user long-presses on this part of the material.
  final GestureLongPressCallback? onLongPress;

  /// The kind of material to show (e.g., card or canvas). This
  /// affects the shape of the widget, the roundness of its corners if
  /// the shape is rectangular, and the default color.
  final MaterialType type;

  /// {@template flutter.material.material.elevation}
  /// The z-coordinate at which to place this material relative to its parent.
  ///
  /// This controls the size of the shadow below the material and the opacity
  /// of the elevation overlay color if it is applied.
  ///
  /// If this is non-zero, the contents of the material are clipped, because the
  /// widget conceptually defines an independent printed piece of material.
  ///
  /// Defaults to 0. Changing this value will cause the shadow and the elevation
  /// overlay or surface tint to animate over [Material.animationDuration].
  ///
  /// The value is non-negative.
  ///
  /// See also:
  ///
  ///  * [ThemeData.useMaterial3] which defines whether a surface tint or
  ///    elevation overlay is used to indicate elevation.
  ///  * [ThemeData.applyElevationOverlayColor] which controls the whether
  ///    an overlay color will be applied to indicate elevation.
  ///  * [Material.color] which may have an elevation overlay applied.
  ///  * [Material.shadowColor] which will be used for the color of a drop shadow.
  ///  * [Material.surfaceTintColor] which will be used as the overlay tint to
  ///    show elevation.
  /// {@endtemplate}
  final double elevation;

  /// The color to paint the material.
  ///
  /// Must be opaque. To create a transparent piece of material, use
  /// [MaterialType.transparency].
  ///
  /// If [ThemeData.useMaterial3] is true then an optional [surfaceTintColor]
  /// overlay may be applied on top of this color to indicate elevation.
  ///
  /// If [ThemeData.useMaterial3] is false and [ThemeData.applyElevationOverlayColor]
  /// is true and [ThemeData.brightness] is [Brightness.dark] then a
  /// semi-transparent overlay color will be composited on top of this
  /// color to indicate the elevation. This is no longer needed for Material
  /// Design 3, which uses [surfaceTintColor].
  ///
  /// By default, the color is derived from the [type] of material.
  final Color? color;

  /// The color to paint the shadow below the material.
  ///
  /// When [ThemeData.useMaterial3] is true, and this is null, then no drop
  /// shadow will be rendered for this material. If it is non-null, then this
  /// color will be used to render a drop shadow below the material.
  ///
  /// When [ThemeData.useMaterial3] is false, and this is null, then
  /// [ThemeData.shadowColor] is used, which defaults to fully opaque black.
  ///
  /// See also:
  ///  * [ThemeData.useMaterial3], which determines the default value for this
  ///    property if it is null.
  ///  * [ThemeData.applyElevationOverlayColor], which turns elevation overlay
  /// on or off for dark themes.
  final Color? shadowColor;

  /// The color of the surface tint overlay applied to the material color
  /// to indicate elevation.
  ///
  /// Material Design 3 introduced a new way for some components to indicate
  /// their elevation by using a surface tint color overlay on top of the
  /// base material [color]. This overlay is painted with an opacity that is
  /// related to the [elevation] of the material.
  ///
  /// If [ThemeData.useMaterial3] is false, then this property is not used.
  ///
  /// If [ThemeData.useMaterial3] is true and [surfaceTintColor] is not null,
  /// then it will be used to overlay the base [color] with an opacity based
  /// on the [elevation].
  ///
  /// Otherwise, no surface tint will be applied.
  ///
  /// See also:
  ///
  ///   * [ThemeData.useMaterial3], which turns this feature on.
  ///   * [ElevationOverlay.applySurfaceTint], which is used to implement the
  ///     tint.
  ///   * https://m3.material.io/styles/color/the-color-system/color-roles
  ///     which specifies how the overlay is applied.
  final Color? surfaceTintColor;

  /// The typographical style to use for text within this material.
  final TextStyle? textStyle;

  /// Defines the material's shape as well its shadow.
  ///
  /// If shape is non null, the [borderRadius] is ignored and the material's
  /// clip boundary and shadow are defined by the shape.
  ///
  /// A shadow is only displayed if the [elevation] is greater than
  /// zero.
  final ShapeBorder? shape;

  /// Whether to paint the [shape] border in front of the [child].
  ///
  /// The default value is true.
  /// If false, the border will be painted behind the [child].
  final bool borderOnForeground;

  /// {@template flutter.material.Material.clipBehavior}
  /// The content will be clipped (or not) according to this option.
  ///
  /// See the enum [Clip] for details of all possible options and their common
  /// use cases.
  /// {@endtemplate}
  ///
  /// Defaults to [Clip.none], and must not be null.
  final Clip clipBehavior;

  /// Defines the duration of animated changes for [shape], [elevation],
  /// [shadowColor], [surfaceTintColor] and the elevation overlay if it is applied.
  ///
  /// The default value is [kThemeChangeDuration].
  final Duration animationDuration;

  /// If non-null, the corners of this box are rounded by this
  /// [BorderRadiusGeometry] value.
  ///
  /// Otherwise, the corners specified for the current [type] of material are
  /// used.
  ///
  /// If [shape] is non null then the border radius is ignored.
  ///
  /// Must be null if [type] is [MaterialType.circle].
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: type,
      elevation: elevation,
      color: color,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      textStyle: textStyle,
      shape: shape,
      borderOnForeground: borderOnForeground,
      clipBehavior: clipBehavior,
      animationDuration: animationDuration,
      borderRadius: borderRadius,
      child: InkResponse(
        highlightShape: BoxShape.rectangle,
        containedInkWell: true,
        onTap: onTap,
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        onTapUp: onTapUp,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        child: child,
      ),
    );
  }
}

class ScalableRippleTap extends StatefulWidget {
  const ScalableRippleTap({
    super.key,
    required this.child,
    this.onTap,
    this.type = MaterialType.canvas,
    this.elevation = 0.0,
    this.color = Colors.transparent,
    this.shadowColor,
    this.surfaceTintColor,
    this.textStyle,
    this.borderRadius,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.antiAlias,
    this.animationDuration = kThemeChangeDuration,
    this.transform,
    this.onDoubleTap,
    this.onLongPress,
  });

  final Widget child;

  /// Called when the user taps this part of the material.
  final GestureTapCallback? onTap;

  /// Called when the user double taps this part of the material.
  final GestureTapCallback? onDoubleTap;

  /// Called when the user long-presses on this part of the material.
  final GestureLongPressCallback? onLongPress;

  final Matrix4? transform;

  /// The kind of material to show (e.g., card or canvas). This
  /// affects the shape of the widget, the roundness of its corners if
  /// the shape is rectangular, and the default color.
  final MaterialType type;

  /// {@template flutter.material.material.elevation}
  /// The z-coordinate at which to place this material relative to its parent.
  ///
  /// This controls the size of the shadow below the material and the opacity
  /// of the elevation overlay color if it is applied.
  ///
  /// If this is non-zero, the contents of the material are clipped, because the
  /// widget conceptually defines an independent printed piece of material.
  ///
  /// Defaults to 0. Changing this value will cause the shadow and the elevation
  /// overlay or surface tint to animate over [Material.animationDuration].
  ///
  /// The value is non-negative.
  ///
  /// See also:
  ///
  ///  * [ThemeData.useMaterial3] which defines whether a surface tint or
  ///    elevation overlay is used to indicate elevation.
  ///  * [ThemeData.applyElevationOverlayColor] which controls the whether
  ///    an overlay color will be applied to indicate elevation.
  ///  * [Material.color] which may have an elevation overlay applied.
  ///  * [Material.shadowColor] which will be used for the color of a drop shadow.
  ///  * [Material.surfaceTintColor] which will be used as the overlay tint to
  ///    show elevation.
  /// {@endtemplate}
  final double elevation;

  /// The color to paint the material.
  ///
  /// Must be opaque. To create a transparent piece of material, use
  /// [MaterialType.transparency].
  ///
  /// If [ThemeData.useMaterial3] is true then an optional [surfaceTintColor]
  /// overlay may be applied on top of this color to indicate elevation.
  ///
  /// If [ThemeData.useMaterial3] is false and [ThemeData.applyElevationOverlayColor]
  /// is true and [ThemeData.brightness] is [Brightness.dark] then a
  /// semi-transparent overlay color will be composited on top of this
  /// color to indicate the elevation. This is no longer needed for Material
  /// Design 3, which uses [surfaceTintColor].
  ///
  /// By default, the color is derived from the [type] of material.
  final Color? color;

  /// The color to paint the shadow below the material.
  ///
  /// When [ThemeData.useMaterial3] is true, and this is null, then no drop
  /// shadow will be rendered for this material. If it is non-null, then this
  /// color will be used to render a drop shadow below the material.
  ///
  /// When [ThemeData.useMaterial3] is false, and this is null, then
  /// [ThemeData.shadowColor] is used, which defaults to fully opaque black.
  ///
  /// See also:
  ///  * [ThemeData.useMaterial3], which determines the default value for this
  ///    property if it is null.
  ///  * [ThemeData.applyElevationOverlayColor], which turns elevation overlay
  /// on or off for dark themes.
  final Color? shadowColor;

  /// The color of the surface tint overlay applied to the material color
  /// to indicate elevation.
  ///
  /// Material Design 3 introduced a new way for some components to indicate
  /// their elevation by using a surface tint color overlay on top of the
  /// base material [color]. This overlay is painted with an opacity that is
  /// related to the [elevation] of the material.
  ///
  /// If [ThemeData.useMaterial3] is false, then this property is not used.
  ///
  /// If [ThemeData.useMaterial3] is true and [surfaceTintColor] is not null,
  /// then it will be used to overlay the base [color] with an opacity based
  /// on the [elevation].
  ///
  /// Otherwise, no surface tint will be applied.
  ///
  /// See also:
  ///
  ///   * [ThemeData.useMaterial3], which turns this feature on.
  ///   * [ElevationOverlay.applySurfaceTint], which is used to implement the
  ///     tint.
  ///   * https://m3.material.io/styles/color/the-color-system/color-roles
  ///     which specifies how the overlay is applied.
  final Color? surfaceTintColor;

  /// The typographical style to use for text within this material.
  final TextStyle? textStyle;

  /// Defines the material's shape as well its shadow.
  ///
  /// If shape is non null, the [borderRadius] is ignored and the material's
  /// clip boundary and shadow are defined by the shape.
  ///
  /// A shadow is only displayed if the [elevation] is greater than
  /// zero.
  final ShapeBorder? shape;

  /// Whether to paint the [shape] border in front of the [child].
  ///
  /// The default value is true.
  /// If false, the border will be painted behind the [child].
  final bool borderOnForeground;

  /// {@template flutter.material.Material.clipBehavior}
  /// The content will be clipped (or not) according to this option.
  ///
  /// See the enum [Clip] for details of all possible options and their common
  /// use cases.
  /// {@endtemplate}
  ///
  /// Defaults to [Clip.none], and must not be null.
  final Clip clipBehavior;

  /// Defines the duration of animated changes for [shape], [elevation],
  /// [shadowColor], [surfaceTintColor] and the elevation overlay if it is applied.
  ///
  /// The default value is [kThemeChangeDuration].
  final Duration animationDuration;

  /// If non-null, the corners of this box are rounded by this
  /// [BorderRadiusGeometry] value.
  ///
  /// Otherwise, the corners specified for the current [type] of material are
  /// used.
  ///
  /// If [shape] is non null then the border radius is ignored.
  ///
  /// Must be null if [type] is [MaterialType.circle].
  final BorderRadiusGeometry? borderRadius;

  @override
  State<ScalableRippleTap> createState() => _ScalableRippleTapState();
}

class _ScalableRippleTapState extends State<ScalableRippleTap> {
  late DateTime _clickTime;

  final _originalTransform = Matrix4.identity();

  late Matrix4 _transform = _originalTransform;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.animationDuration,
      transformAlignment: Alignment.center,
      transform: _transform,
      child: RippleTap(
        type: widget.type,
        elevation: widget.elevation,
        color: widget.color,
        shadowColor: widget.shadowColor,
        surfaceTintColor: widget.surfaceTintColor,
        textStyle: widget.textStyle,
        shape: widget.shape,
        borderOnForeground: widget.borderOnForeground,
        clipBehavior: widget.clipBehavior,
        animationDuration: widget.animationDuration,
        borderRadius: widget.borderRadius,
        onTap: widget.onTap,
        onTapDown: (_) => _scaleStart(),
        onTapCancel: _scaleEnd,
        onTapUp: (_) => _scaleEnd(),
        onLongPress: widget.onLongPress,
        onDoubleTap: widget.onDoubleTap,
        child: widget.child,
      ),
    );
  }

  Future<void> _scaleEnd() async {
    final diff = DateTime.now().difference(_clickTime);
    if (diff < widget.animationDuration) {
      await Future.delayed(widget.animationDuration - diff);
    }
    if (mounted) {
      setState(() {
        _transform = _originalTransform;
      });
    }
  }

  void _scaleStart() {
    _clickTime = DateTime.now();
    if (mounted) {
      setState(() {
        _transform = widget.transform ?? Matrix4.diagonal3Values(0.96, 0.96, 1);
      });
    }
  }
}
