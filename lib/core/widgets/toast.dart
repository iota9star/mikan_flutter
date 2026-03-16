import 'package:flutter/material.dart';

class ToastWidget extends StatelessWidget {
  const ToastWidget({super.key, required this.msg});

  final String msg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: ShapeDecoration(
        color: theme.colorScheme.inverseSurface,
        shape: const RoundedSuperellipseBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Text(msg, style: TextStyle(color: theme.colorScheme.onInverseSurface)),
    );
  }
}
