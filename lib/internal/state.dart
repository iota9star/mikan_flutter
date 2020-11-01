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
    logd("页面 ${widget.runtimeType} => initStated.");
  }

  @override
  void dispose() {
    logd("页面 ${widget.runtimeType} => disposed.");
    super.dispose();
  }
}

abstract class CacheWidgetPageState<T extends StatefulWidget>
    extends CacheWidgetState<T> {
  @override
  void initState() {
    super.initState();
    logd("页面 ${widget.runtimeType} => initStated.");
  }

  @override
  void dispose() {
    logd("页面 ${widget.runtimeType} => disposed.");
    super.dispose();
  }
}

@immutable
abstract class CacheStatelessWidget extends StatelessWidget {
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
