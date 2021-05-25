import 'package:flutter/widgets.dart';
import 'package:mikan_flutter/internal/extension.dart';

abstract class PageState<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    "State页面 ${widget.runtimeType} => initStated.".debug();
  }

  @override
  void dispose() {
    super.dispose();
    "State页面 ${widget.runtimeType} => disposed.".debug();
  }
}
