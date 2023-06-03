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
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      barrierColor: barrierColor,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final clipRRect = ClipRRect(
      borderRadius: borderRadius28,
      child: child,
    );
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 16.0 + navKey.currentContext!.navBarHeight,
        top: heightFactor == 1.0
            ? navKey.currentContext!.statusBarHeight + 16.0
            : 16.0,
      ),
      child: height != null
          ? SizedBox(
              height: height,
              child: clipRRect,
            )
          : FractionallySizedBox(
              heightFactor: heightFactor,
              child: clipRRect,
            ),
    );
  }
}
