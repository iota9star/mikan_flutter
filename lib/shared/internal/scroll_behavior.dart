import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AlwaysStretchScrollBehavior extends ScrollBehavior {
  const AlwaysStretchScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();

  @override
  TargetPlatform getPlatform(BuildContext context) => TargetPlatform.android;

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      clipBehavior: details.decorationClipBehavior ?? Clip.hardEdge,
      child: child,
    );
  }
}
