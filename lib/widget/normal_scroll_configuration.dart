import 'package:flutter/material.dart';
import 'package:mikan_flutter/topvars.dart';

class NormalScrollConfiguration extends StatelessWidget {
  const NormalScrollConfiguration({Key? key, required this.child})
      : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: normalScrollBehavior,
      child: child,
    );
  }
}
