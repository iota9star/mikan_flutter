import 'package:flutter/widgets.dart';
import 'package:mikan_flutter/internal/logger.dart';

abstract class CacheWidgetState<T extends StatefulWidget> extends State<T> {
  Widget _cacheWidget;

  @override
  Widget build(BuildContext context) {
    if (_cacheWidget == null) {
      _cacheWidget = buildCacheWidget(context);
    }
    return _cacheWidget;
  }

  Widget buildCacheWidget(BuildContext context) => null;
}

abstract class PageState<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    logd("State页面 ${widget.runtimeType} => initStated.");
  }

  @override
  void dispose() {
    logd("State页面 ${widget.runtimeType} => disposed.");
    super.dispose();
  }
}
