import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

const _esc = '\x1B[';
const _reset = '${_esc}0m';
const _black = '${_esc}30m';
const _red = '${_esc}31m';
const _green = '${_esc}32m';
const _yellow = '${_esc}33m';
const _blue = '${_esc}34m';
const _magenta = '${_esc}35m';
const _cyan = '${_esc}36m';
const _white = '${_esc}37m';
const _grey = '${_esc}90m';
const _line =
    "════════════════════════════════════════════════════════════════════════════════════════════════════";

extension Log on Object? {
  void debug({String? tag, StackTrace? stackTrace, int level = 2}) {
    d(this, tag: tag, stackTrace: stackTrace, level: level);
  }

  void info({String? tag, StackTrace? stackTrace, int level = 2}) {
    i(this, tag: tag, stackTrace: stackTrace, level: level);
  }

  void warn({String? tag, StackTrace? stackTrace, int level = 2}) {
    w(this, tag: tag, stackTrace: stackTrace, level: level);
  }

  void error({
    Object? msg,
    String? tag,
    StackTrace? stackTrace,
    int level = 2,
  }) {
    e(msg: msg, tag: tag, error: this, stackTrace: stackTrace, level: level);
  }

  static void d(
    Object? msg, {
    String? tag,
    StackTrace? stackTrace,
    int level = 1,
  }) {
    if (!kDebugMode) {
      return;
    }
    final track = tag ?? _trackStackTraceId(StackTrace.current, level);
    _log(
      msg: msg,
      track: track,
      stackTrace: stackTrace,
      level: ' D ',
      levelColor: _grey,
    );
  }

  static void i(
    Object? msg, {
    String? tag,
    StackTrace? stackTrace,
    int level = 1,
  }) {
    final track = tag ?? _trackStackTraceId(StackTrace.current, level);
    _log(
      msg: msg,
      track: track,
      stackTrace: stackTrace,
      level: ' I ',
      levelColor: _cyan,
    );
  }

  static void w(
    Object? msg, {
    String? tag,
    StackTrace? stackTrace,
    int level = 1,
  }) {
    final track = tag ?? _trackStackTraceId(StackTrace.current, level);
    _log(
      msg: msg,
      track: track,
      stackTrace: stackTrace,
      level: ' W ',
      levelColor: _yellow,
    );
  }

  static void e({
    Object? msg,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    int level = 1,
  }) {
    final track = tag ?? _trackStackTraceId(StackTrace.current, level);
    _log(
      msg: msg,
      track: track,
      error: error,
      stackTrace: stackTrace,
      level: ' E ',
      levelColor: _red,
    );
  }

  static _log({
    Object? msg,
    required String level,
    required String levelColor,
    required String track,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final es = [error, stackTrace].whereNotNull().join("\n\n");
    final hasError = es.isNotEmpty;
    final buffer = StringBuffer();
    buffer.write(_wrapReverse(_wrapBold(_wrapColor(levelColor, level))));
    buffer.write(" ");
    buffer.write(_wrapColor(_white, _logTime()));
    buffer.write(" ");
    buffer.write(_wrapColor(_white, track));
    buffer.write(" ");
    buffer.write(_wrapReverse(_wrapColor(levelColor, _wrapBold(" => "))));
    buffer.write(" ");
    if (msg != null) {
      buffer.write(msg.toString());
    }
    if (hasError) {
      buffer.writeln();
      buffer.writeln(_wrapColor(levelColor, _line));
      buffer.writeln(_wrapColor(levelColor, es));
      buffer.write(_wrapColor(levelColor, _line));
    }
    stdout.writeln(buffer.toString());
  }

  static String _trackStackTraceId(StackTrace stackTrace, int level) {
    return stackTrace
        .toString()
        .split('\n')[level]
        .replaceAll(RegExp(r'(#\d+\s+)'), '')
        .replaceAll(RegExp(r'(<anonymous closure>)'), '()')
        .replaceAll('. (', '.() (');
  }

  static String _wrapColor(String color, Object? text) {
    return '$color$text$_reset';
  }

  static String _wrapBold(Object? text) {
    return '${_esc}1m$text$_reset';
  }

  static String _wrapReverse(Object? text) {
    return '${_esc}7m$text$_reset';
  }

  static String _logTime() {
    final now = DateTime.now();
    return '${now.year}'
        '-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}'
        ' ${now.hour.toString().padLeft(2, '0')}'
        ':${now.minute.toString().padLeft(2, '0')}'
        ':${now.second.toString().padLeft(2, '0')}';
  }
}
