import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../topvars.dart';

Future<T> wrapLoading<T>(
  FutureOr<T> Function() block, {
  String msg = '加载中...',
}) async {
  try {
    unawaited(
      SmartDialog.showLoading(
        backType: SmartBackType.block,
        clickMaskDismiss: false,
        maskColor: Theme.of(navKey.currentContext!)
            .colorScheme
            .surface
            .withValues(alpha: 0.64),
        msg: msg,
      ),
    );
    return await block();
  } finally {
    await SmartDialog.dismiss();
  }
}

Future<void> hideKeyboard() {
  return SystemChannels.textInput
      .invokeMethod('TextInput.hide')
      .catchError((_) {});
}
