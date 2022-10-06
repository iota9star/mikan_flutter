import 'package:flutter/material.dart';
import 'package:mikan_flutter/topvars.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    this.iconData,
    this.backgroundColor,
    required this.onPressed,
    this.size = 32.0,
    this.iconSize = 16.0,
    this.child,
    this.tooltip,
    this.iconColor,
  }) : super(key: key);

  final IconData? iconData;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final Widget? child;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final body = Material(
      shape: circleShape,
      clipBehavior: Clip.hardEdge,
      color: backgroundColor,
      child: InkResponse(
        onTap: onPressed,
        child: child ??
            SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Icon(
                  iconData,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
            ),
      ),
    );
    return tooltip == null
        ? body
        : Tooltip(
            message: tooltip,
            child: body,
          );
  }
}
