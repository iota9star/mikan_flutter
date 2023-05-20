import 'package:flutter/material.dart';

import '../internal/kit.dart';
import '../topvars.dart';

class MBottomSheet extends StatelessWidget {
  const MBottomSheet({
    super.key,
    required this.child,
    this.heightFactor = 0.618,
  });

  final Widget child;
  final double heightFactor;

  static Future<void> show(BuildContext context, WidgetBuilder builder) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 16.0 + navKey.currentContext!.navBarHeight,
        top: heightFactor == 1.0
            ? navKey.currentContext!.statusBarHeight + 16.0
            : 16.0,
      ),
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        child: ClipRRect(
          borderRadius: borderRadius28,
          child: child,
        ),
      ),
    );
  }
}
