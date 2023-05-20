import 'package:flutter/material.dart';

class Restart extends StatefulWidget {
  Restart({super.key, required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<RestartState>()!.restartApp();
  }

  @override
  RestartState createState() => RestartState();
}

class RestartState extends State<Restart> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
