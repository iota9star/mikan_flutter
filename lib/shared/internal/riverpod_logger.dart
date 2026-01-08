import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'log.dart';

base class RiverpodLogger extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderObserverContext context, Object? previousValue, Object? newValue) {
    if (kDebugMode) {
      final providerName = context.provider.name ?? context.provider.runtimeType.toString();
      'Riverpod: [$providerName] updated'.$debug();
    }
  }

  @override
  void providerDidFail(ProviderObserverContext context, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      final providerName = context.provider.name ?? context.provider.runtimeType.toString();
      'Riverpod: [$providerName] failed with error: $error'.$error(stackTrace: stackTrace);
    }
  }

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    if (kDebugMode) {
      final providerName = context.provider.name ?? context.provider.runtimeType.toString();
      'Riverpod: [$providerName] initialized'.$debug();
    }
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    if (kDebugMode) {
      final providerName = context.provider.name ?? context.provider.runtimeType.toString();
      'Riverpod: [$providerName] disposed'.$debug();
    }
  }
}
