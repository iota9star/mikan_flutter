import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:mikan/core/common/app_layout.dart';

// ============ Platform ============
final isMobile = Platform.isIOS || Platform.isAndroid;
final isSupportFirebase = isMobile || Platform.isMacOS;
final isDesktop = Platform.isMacOS || Platform.isLinux || Platform.isWindows;

// ============ Spacing ============
class Spacing {
  const Spacing._();

  /// Extra small spacing (4px) - used for tight spacing
  static const double xs = 4.0;

  /// Small spacing (8px) - used between related elements
  static const double sm = 8.0;

  /// Medium spacing (12px) - used for moderate separation
  static const double md = 12.0;

  /// Large spacing (16px) - used for major sections
  static const double lg = 16.0;

  /// Extra large spacing (24px) - used for page-level padding
  static const double xl = 24.0;

  /// Extra extra large spacing (32px) - used for dramatic spacing
  static const double xxl = 32.0;

  /// Extra extra extra large (48px) - used for special cases
  static const double xxxl = 48.0;
}

// ============ UI Methods ============
Future<T> wrapLoading<T>(FutureOr<T> Function() block, {String msg = '加载中...'}) async {
  final dialogContext = navKey.currentContext ?? navKey.currentState?.context;
  final maskColor = dialogContext != null
      ? Theme.of(dialogContext).colorScheme.surface.withValues(alpha: 0.64)
      : Colors.black54;

  try {
    unawaited(
      SmartDialog.showLoading(backType: SmartBackType.block, clickMaskDismiss: false, maskColor: maskColor, msg: msg),
    );
    return await block();
  } finally {
    await SmartDialog.dismiss();
  }
}

Future<void> hideKeyboard() {
  return SystemChannels.textInput.invokeMethod('TextInput.hide').catchError((_) {});
}
