import 'dart:collection';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:mikan_flutter/internal/extension.dart';

class BaseModel extends ChangeNotifier {
  bool _disposed = false;

  bool get disposed => _disposed;

  @override
  void notifyListeners() {
    if (_disposed) {
      "waiting notify, but disposed, ignore...".debug();
      return;
    }
    "notify...".debug();
    super.notifyListeners();
  }

  @mustCallSuper
  @override
  void dispose() {
    _disposed = true;
    "disposed.".debug();
    super.dispose();
  }
}

class CancelableBaseModel extends BaseModel {
  final ListQueue<CancelableCompleter> _jobs = ListQueue();

  @mustCallSuper
  @override
  void dispose() {
    CancelableCompleter job;
    "等待取消任务: ${_jobs.length}".debug();
    while (_jobs.isNotEmpty) {
      job = _jobs.removeFirst();
      job.operation.cancel();
    }
    super.dispose();
  }

  Future operator +(Future future) {
    CancelableCompleter completer = CancelableCompleter(onCancel: () {
      "取消了一个任务".debug();
    });
    _jobs.add(completer);
    completer.complete(future);
    completer.operation.value.catchError((e) {
      "$runtimeType: $e".debug();
    }).whenComplete(() {
      _jobs.remove(completer);
      "$runtimeType 执行完了一个任务".debug();
    });
    return completer.operation.value;
  }
}
