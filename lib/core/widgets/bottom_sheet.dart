import 'package:flutter/material.dart';

import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/core/common/kit.dart';

/// A styled bottom sheet with rounded corners and proper padding.
class MBottomSheet extends StatelessWidget {
  const MBottomSheet({super.key, required this.child, this.height, this.heightFactor = 0.618});

  final Widget child;
  final double? height;
  final double heightFactor;

  /// Shows a modal bottom sheet with the given builder.
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
    final navContext = navKey.currentContext ?? navKey.currentState?.context ?? context;

    final clipRRect = ClipRSuperellipse(borderRadius: const BorderRadius.all(Radius.circular(24.0)), child: child);

    return Material(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.27),
      shape: const RoundedSuperellipseBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28.0))),
      child: Padding(
        padding: EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          bottom: 8.0 + navContext.navBarHeight,
          top: heightFactor == 1.0 ? navContext.statusBarHeight + 8.0 : 8.0,
        ),
        child: height != null
            ? SizedBox(height: height, child: clipRRect)
            : FractionallySizedBox(heightFactor: heightFactor, child: clipRRect),
      ),
    );
  }
}
