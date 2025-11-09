import 'package:flutter/material.dart';

import '../internal/kit.dart';
import '../topvars.dart';

class MBottomSheet extends StatelessWidget {
  const MBottomSheet({
    super.key,
    required this.child,
    this.height,
    this.heightFactor = 0.618,
  });

  final Widget child;
  final double? height;
  final double heightFactor;

  static Future<void> show(
    BuildContext context,
    WidgetBuilder builder, {
    Color? barrierColor,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      barrierColor: barrierColor,
      backgroundColor: Colors.transparent,
      builder: builder,
      elevation: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final clipRRect = ClipRRect(
      borderRadius: borderRadiusT28,
      child: child,
    );
    return height != null
        ? SizedBox(
            height: height,
            child: clipRRect,
          )
        : FractionallySizedBox(
            heightFactor: heightFactor,
            child: clipRRect,
          );
  }
}
