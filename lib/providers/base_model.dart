import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:mikan_flutter/internal/extension.dart';

class BaseModel extends ChangeNotifier {
  bool _disposed = false;

  bool get disposed => _disposed;

  @override
  void notifyListeners() {
    if (_disposed) {
      "waiting notify, but disposed, ignore...".debug(level: 3);
      return;
    }
    "notify...".debug(level: 3);
    super.notifyListeners();
  }

  @mustCallSuper
  @override
  void dispose() {
    _disposed = true;
    "disposed.".debug(level: 3);
    super.dispose();
  }
}

class CancelableBaseModel extends BaseModel {
  final Set<CancelableCompleter> _jobs = <CancelableCompleter>{};

  @mustCallSuper
  @override
  void dispose() async {
    "等待取消任务: ${_jobs.length}".debug(level: 3);
    if (_jobs.isNotEmpty) {
      await Future.wait(_jobs.map((job) => job.operation.cancel()));
    }
    super.dispose();
  }

  Future operator +(Future future) {
    final CancelableCompleter completer = CancelableCompleter(onCancel: () {
      "取消了一个任务".debug(level: 3);
    });
    _jobs.add(completer);
    future.then((value) {
      completer.complete(future);
    }).catchError((dynamic err, StackTrace stackTrace) {
      "$err: $stackTrace".debug(level: 3);
      completer.completeError(err, stackTrace);
    }).whenComplete(() {
      _jobs.remove(completer);
      "执行完了一个任务".debug();
    });
    return completer.operation.value;
  }
}
