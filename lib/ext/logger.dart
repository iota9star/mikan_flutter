import 'package:flutter/foundation.dart';

void logd(dynamic msg, [dynamic tag]) {
  Log.d(msg, tag);
}

class Log {
  const Log._();

  static const int _limit = 800;

  static void d(dynamic msg, [dynamic tag]) {
    if (kDebugMode) {
      _log(msg.toString(), tag ?? "");
    }
  }

  static void _log(String msg, dynamic tag) {
    if (msg.length < _limit) {
      debugPrint("$msg");
    } else {
      _slog(msg, tag);
    }
  }

  static void _slog(String msg, dynamic tag) {
    var sb = StringBuffer();
    var lastIndex;
    var length = msg.length;
    for (var index = 0; index < length; index++) {
      sb.write(msg[index]);
      if (index % _limit == 0 && index != 0) {
        debugPrint("$sb");
        sb.clear();
        lastIndex = index + 1;
        if (length - lastIndex < _limit) {
          debugPrint(
              "${msg.substring(lastIndex, length)}");
          break;
        }
      }
    }
  }
}
