import 'package:flutter/cupertino.dart';

import '../internal/log.dart';

class BaseModel extends ChangeNotifier {
  bool _disposed = false;

  bool get disposed => _disposed;

  @override
  void notifyListeners() {
    if (_disposed) {
      'waiting notify, but disposed, ignore...'.$debug(level: 3);
      return;
    }
    'notify...'.$debug(level: 3);
    super.notifyListeners();
  }

  @mustCallSuper
  @override
  void dispose() {
    _disposed = true;
    'disposed.'.$debug(level: 3);
    super.dispose();
  }
}
