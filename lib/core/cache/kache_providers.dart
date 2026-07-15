import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/kache.dart';
import 'package:kache_riverpod/kache_riverpod.dart';

import 'package:mikan/core/cache/kache_init.dart';

/// Provides the application-wide [KacheClient].
///
/// The client is created during bootstrap ([KacheInit.init]) and lives for the
/// entire application lifetime.
final kacheClientProvider = Provider<KacheClient>((ref) {
  return KacheInit.client;
});

/// Convenience extension that mirrors [AsyncValue.when] semantics on top of
/// [KacheSnapshot], so the UI can consume Kache providers without learning a
/// new pattern.
///
/// ```dart
/// final snapshot = ref.watch(seasonProvider(season));
/// snapshot.when(
///   data: (SeasonData data) => ...,
///   loading: () => ...,
///   error: (error, stack) => ...,
/// );
/// ```
extension KacheSnapshotWhenExtension<T> on KacheSnapshot<T> {
  R when<R>({
    required R Function(T data) data,
    required R Function() loading,
    required R Function(Object error, StackTrace stackTrace) error,
  }) {
    if (hasData) {
      return data(requireData);
    }
    if (phase == KachePhase.failure) {
      final f = failure;
      if (f != null) {
        return error(f.cause, f.stackTrace);
      }
    }
    return loading();
  }

  /// Like [when] but keeps previous data visible during background refresh
  /// or refresh failure — pass [previousData] to fall back to.
  R whenData<R>({
    required R Function(T data) data,
    required R Function() loading,
    required R Function(Object error, StackTrace stackTrace) error,
    T? previousData,
  }) {
    if (hasData) {
      return data(requireData);
    }
    if (previousData != null) {
      return data(previousData);
    }
    if (phase == KachePhase.failure) {
      final f = failure;
      if (f != null) {
        return error(f.cause, f.stackTrace);
      }
    }
    return loading();
  }
}

/// Logs [KacheEvent]s in debug mode for observability.
void debugLogKacheEvent(KacheEvent event) {
  if (!kDebugMode) {
    return;
  }
  debugPrint('[Kache] ${event.kind.name}'
      '${event.key != null ? ' key=${event.key!.storageKey}' : ''}'
      '${event.namespace != null ? ' ns=${event.namespace!.value}' : ''}'
      '${event.failure != null ? ' failure=${event.failure!.kind.name}' : ''}');
}
