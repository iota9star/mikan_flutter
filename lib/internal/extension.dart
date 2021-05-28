import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

extension IterableExt<T> on Iterable<T>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isSafeNotEmpty => !this.isNullOrEmpty;

  T? getOrNull(final int index) {
    if (this.isNullOrEmpty) return null;
    return this!.elementAt(index);
  }

  bool eq(Iterable<T>? other) {
    if (this == null) return other == null;
    if (other == null || this!.length != other.length) return false;
    for (int index = 0; index < this!.length; index += 1) {
      if (this!.elementAt(index) != other.elementAt(index)) return false;
    }
    return true;
  }

  bool ne(Iterable<T> other) => !this.eq(other);
}

extension BoolExt on bool {
  bool get inv => !this;
}

extension ListExt<T> on List<T>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isSafeNotEmpty => !this.isNullOrEmpty;

  T? getOrNull(final int index) {
    if (this.isNullOrEmpty) return null;
    return this![index];
  }

  bool eq(List<T>? other) {
    if (this == null) return other == null;
    if (other == null || this!.length != other.length) return false;
    for (int index = 0; index < this!.length; index += 1) {
      if (this![index] != other[index]) return false;
    }
    return true;
  }

  bool ne(List<T>? other) => !this.eq(other);
}

extension MapExt<K, V> on Map<K, V>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isSafeNotEmpty => !this.isNullOrEmpty;

  bool eq(Map<K, V>? other) {
    if (this == null) return other == null;
    if (other == null || this!.length != other.length) return false;
    for (final K key in this!.keys) {
      if (!other.containsKey(key) || other[key] != this![key]) {
        return false;
      }
    }
    return true;
  }

  bool ne(Map<K, V>? other) => !this.eq(other);
}

extension NullableStringExt on String? {
  bool get isNullOrBlank => this == null || this!.isBlank;

  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotBlank => this != null && !this!.isBlank;

  toast() async {
    if (this.isNullOrBlank) {
      return;
    }
    showToastWidget(
      Builder(
        builder: (context) {
          final Color bgc = Theme.of(context).accentColor;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: edgeH16V12,
                margin: edgeH8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [bgc, bgc.withOpacity(0.87)],
                  ),
                  borderRadius: borderRadius8,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.024),
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      spreadRadius: 3.0,
                    ),
                  ],
                ),
                child: Text(
                  this!,
                  style: TextStyle(
                    color: bgc.computeLuminance() < 0.5
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  launchAppAndCopy() async {
    if (this.isNullOrBlank) return "内容为空，取消操作".toast();
    Future _doOtherAction() async {
      if (await canLaunch(this!)) {
        await launch(this!);
      } else {
        "未找到可打开应用".toast();
      }
    }

    await FlutterClipboard.copy(this!);
    if (Platform.isAndroid) {
      AndroidIntent(
        action: "android.intent.action.VIEW",
        flags: [
          Flag.FLAG_ACTIVITY_NEW_TASK,
          Flag.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
        ],
        data: this!,
      ).launch().catchError((e) async {
        await _doOtherAction();
      });
    } else {
      await _doOtherAction();
    }
  }

  copy() {
    if (this.isNullOrBlank) return "内容为空，取消操作".toast();
    FlutterClipboard.copy(this!).then((_) => "成功复制到剪切板".toast());
  }

  share() {
    if (this.isNullOrBlank) return "内容为空，取消操作".toast();
    Share.share(this!);
    FlutterClipboard.copy(this!).then((_) => "尝试分享，并复制到剪切板".toast());
  }
}

extension StringExt on String {
  bool get isBlank {
    if (this.length == 0) {
      return true;
    }
    for (var value in this.runes) {
      if (!this._isWhitespace(value)) {
        return false;
      }
    }
    return true;
  }

  bool _isWhitespace(int rune) =>
      (rune >= 0x0009 && rune <= 0x000D) ||
      rune == 0x0020 ||
      rune == 0x0085 ||
      rune == 0x00A0 ||
      rune == 0x1680 ||
      rune == 0x180E ||
      (rune >= 0x2000 && rune <= 0x200A) ||
      rune == 0x2028 ||
      rune == 0x2029 ||
      rune == 0x202F ||
      rune == 0x205F ||
      rune == 0x3000 ||
      rune == 0xFEFF;

  String fillChar(String value, String char) {
    var offset = value.length - this.length;
    var newVal = this;
    if (offset > 0) {
      for (int i = 0; i < offset; i++) {
        newVal = char + newVal;
      }
    }
    return newVal;
  }
}

final DateFormat _logDateFormatter = DateFormat("HH:mm:ss.SSS");

extension Log on Object? {
  debug({int level = 2}) {
    d(this, level: level);
  }

  error({StackTrace? trace, int level = 2}) {
    e(this, trace: trace, level: level);
  }

  static void e(dynamic any, {StackTrace? trace, int level = 1}) {
    if (kDebugMode) {
      final String tag;
      if (trace != null) {
        tag =
            "${_logDateFormatter.format(DateTime.now())} E/${trace.toString().split("\n")[level].replaceAll(RegExp("(#\\d+\\s+)|(<anonymous closure>)"), "").replaceAll(". (", ".() (")} => ";
      } else {
        tag = "${_logDateFormatter.format(DateTime.now())} E => ";
      }
      Log.p(any, tag: tag);
    }
  }

  static void d(dynamic any, {int level = 1}) {
    if (kDebugMode) {
      final String tag =
          "${_logDateFormatter.format(DateTime.now())} D/${StackTrace.current.toString().split("\n")[level].replaceAll(RegExp("(#\\d+\\s+)|(<anonymous closure>)"), "").replaceAll(". (", ".() (")} => ";
      Log.p(any, tag: tag);
    }
  }

  static void p(dynamic msg, {int wrapWidth = 800, String tag = "DEBUG"}) {
    if (kDebugMode) {
      _debugPrintThrottled(
        msg.toString(),
        wrapWidth: wrapWidth + tag.length,
        tag: tag,
      );
    }
  }
}

/// Implementation of [debugPrint] that throttles messages. This avoids dropping
/// messages on platforms that rate-limit their logging (for example, Android).
void _debugPrintThrottled(String? message, {int? wrapWidth, String? tag}) {
  final List<String> messageLines = message?.split('\n') ?? <String>['null'];
  if (wrapWidth != null) {
    _debugPrintBuffer.addAll(!tag.isNullOrBlank
        ? messageLines.expand<String>(
            (String line) => _debugWordWrap("$tag$line", wrapWidth))
        : messageLines
            .expand<String>((String line) => _debugWordWrap(line, wrapWidth)));
  } else {
    _debugPrintBuffer.addAll(messageLines);
  }
  if (!_debugPrintScheduled) _debugPrintTask();
}

int _debugPrintedCharacters = 0;
const int _kDebugPrintCapacity = 12 * 1024;
const Duration _kDebugPrintPauseTime = Duration(seconds: 1);
final Queue<String> _debugPrintBuffer = Queue<String>();
final Stopwatch _debugPrintStopwatch = Stopwatch();
Completer<void>? _debugPrintCompleter;
bool _debugPrintScheduled = false;

void _debugPrintTask() {
  _debugPrintScheduled = false;
  if (_debugPrintStopwatch.elapsed > _kDebugPrintPauseTime) {
    _debugPrintStopwatch.stop();
    _debugPrintStopwatch.reset();
    _debugPrintedCharacters = 0;
  }
  while (_debugPrintedCharacters < _kDebugPrintCapacity &&
      _debugPrintBuffer.isNotEmpty) {
    final String line = _debugPrintBuffer.removeFirst();
    _debugPrintedCharacters +=
        line.length; // TODO(ianh): Use the UTF-8 byte length instead
    print(line);
  }
  if (_debugPrintBuffer.isNotEmpty) {
    _debugPrintScheduled = true;
    _debugPrintedCharacters = 0;
    Timer(_kDebugPrintPauseTime, _debugPrintTask);
    _debugPrintCompleter ??= Completer<void>();
  } else {
    _debugPrintStopwatch.start();
    _debugPrintCompleter?.complete();
    _debugPrintCompleter = null;
  }
}

/// A Future that resolves when there is no longer any buffered content being
/// printed by [debugPrintThrottled] (which is the default implementation for
/// [debugPrint], which is used to report errors to the console).
Future<void> get debugPrintDone =>
    _debugPrintCompleter?.future ?? Future<void>.value();

final RegExp _indentPattern = RegExp('^ *(?:[-+*] |[0-9]+[.):] )?');
enum _WordWrapParseMode { inSpace, inWord, atBreak }

/// Wraps the given string at the given width.
///
/// Wrapping occurs at space characters (U+0020). Lines that start with an
/// octothorpe ("#", U+0023) are not wrapped (so for example, Dart stack traces
/// won't be wrapped).
///
/// Subsequent lines attempt to duplicate the indentation of the first line, for
/// example if the first line starts with multiple spaces. In addition, if a
/// `wrapIndent` argument is provided, each line after the first is prefixed by
/// that string.
///
/// This is not suitable for use with arbitrary Unicode text. For example, it
/// doesn't implement UAX #14, can't handle ideographic text, doesn't hyphenate,
/// and so forth. It is only intended for formatting error messages.
///
/// The default [debugPrint] implementation uses this for its line wrapping.
Iterable<String> _debugWordWrap(String message, int width,
    {String wrapIndent = ''}) sync* {
  if (message.length < width || message.trimLeft()[0] == '#') {
    yield message;
    return;
  }
  final Match prefixMatch = _indentPattern.matchAsPrefix(message)!;
  final String prefix = wrapIndent + ' ' * prefixMatch.group(0)!.length;
  int start = 0;
  int startForLengthCalculations = 0;
  bool addPrefix = false;
  int index = prefix.length;
  _WordWrapParseMode mode = _WordWrapParseMode.inSpace;
  late int lastWordStart;
  int? lastWordEnd;
  while (true) {
    switch (mode) {
      case _WordWrapParseMode
          .inSpace: // at start of break point (or start of line); can't break until next break
        while ((index < message.length) && (message[index] == ' ')) index += 1;
        lastWordStart = index;
        mode = _WordWrapParseMode.inWord;
        break;
      case _WordWrapParseMode.inWord: // looking for a good break point
        while ((index < message.length) && (message[index] != ' ')) index += 1;
        mode = _WordWrapParseMode.atBreak;
        break;
      case _WordWrapParseMode.atBreak: // at start of break point
        if ((index - startForLengthCalculations > width) ||
            (index == message.length)) {
          // we are over the width line, so break
          if ((index - startForLengthCalculations <= width) ||
              (lastWordEnd == null)) {
            // we should use this point, because either it doesn't actually go over the
            // end (last line), or it does, but there was no earlier break point
            lastWordEnd = index;
          }
          if (addPrefix) {
            yield prefix + message.substring(start, lastWordEnd);
          } else {
            yield message.substring(start, lastWordEnd);
            addPrefix = true;
          }
          if (lastWordEnd >= message.length) return;
          // just yielded a line
          if (lastWordEnd == index) {
            // we broke at current position
            // eat all the spaces, then set our start point
            while ((index < message.length) && (message[index] == ' '))
              index += 1;
            start = index;
            mode = _WordWrapParseMode.inWord;
          } else {
            // we broke at the previous break point, and we're at the start of a new one
            assert(lastWordStart > lastWordEnd);
            start = lastWordStart;
            mode = _WordWrapParseMode.atBreak;
          }
          startForLengthCalculations = start - prefix.length;
          assert(addPrefix);
          lastWordEnd = null;
        } else {
          // save this break point, we're not yet over the line width
          lastWordEnd = index;
          // skip to the end of this break point
          mode = _WordWrapParseMode.inSpace;
        }
        break;
    }
  }
}

extension RefreshControllerExt on RefreshController {
  completed({bool noMore = false}) {
    if (this.isRefresh) {
      this.refreshCompleted();
    } else if (this.isLoading) {
      if (noMore) {
        this.loadNoData();
      } else {
        this.loadComplete();
      }
    }
  }

  failed() {
    if (this.isRefresh) {
      this.refreshFailed();
    } else if (this.isLoading) {
      this.loadFailed();
    }
  }
}

/// https://stackoverflow.com/a/50081214/10064463
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

const SystemUiOverlayStyle _light = SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  statusBarColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

const SystemUiOverlayStyle _dark = SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  statusBarColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

extension BuildContextExt on BuildContext {
  SystemUiOverlayStyle get fitSystemUiOverlayStyle {
    return Theme.of(this).scaffoldBackgroundColor.computeLuminance() < 0.5
        ? _light
        : _dark;
  }
}

extension BrightnessColor on Color {
  static Color lightRandom() {
    return HSLColor.fromAHSL(
      1,
      math.Random().nextDouble() * 360,
      0.5,
      0.75,
    ).toColor();
  }

  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}

eee() {}
