import 'dart:collection';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:mikan_flutter/internal/logger.dart';

class BaseModel extends ChangeNotifier {
  bool _disposed = false;

  bool get disposed => _disposed;

  @override
  void notifyListeners() {
    if (_disposed) {
      logd("disposed, return.", this.runtimeType);
      return;
    }
    logd("notify...", this.runtimeType);
    super.notifyListeners();
  }

  @mustCallSuper
  @override
  void dispose() {
    _disposed = true;
    logd("disposed.", this.runtimeType);
    super.dispose();
  }
}

class CancelableBaseModel extends BaseModel {
  final ListQueue<CancelableCompleter> _jobs = ListQueue();

  @mustCallSuper
  @override
  void dispose() {
    CancelableCompleter job;
    logd("等待取消任务: ${_jobs.length}", this.runtimeType);
    while (_jobs.isNotEmpty) {
      job = _jobs.removeFirst();
      job.operation.cancel();
    }
    super.dispose();
  }

  Future operator +(Future future) {
    CancelableCompleter completer = CancelableCompleter(onCancel: () {
      logd("取消了一个任务...", this.runtimeType);
    });
    _jobs.add(completer);
    completer.complete(future);
    completer.operation.value.then((value) {
      if (this._disposed) {
        logd("$runtimeType 当前model已disposed，打断施法...");
        throw "当前model已disposed，打断施法...";
      }
      return value;
    }).catchError((e) {
      logd("$runtimeType: $e");
    }).whenComplete(() {
      _jobs.remove(completer);
      logd("$runtimeType 执行完了一个任务...");
    });
    return completer.operation.value;
  }
}
