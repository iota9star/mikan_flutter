import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/kache.dart';
import 'package:kache_riverpod/kache_riverpod.dart';

import 'package:mikan/core/cache/kache_init.dart';

/// Provides the application-wide [KacheClient].
///
/// The client is created during bootstrap ([KacheInit.init]) and lives for the
/// entire application lifetime. It is exposed as a Riverpod provider so that
/// kacheProvider-based providers can resolve it through `Ref`.
final kacheClientProvider = Provider<KacheClient>((ref) {
  return KacheInit.client;
});

/// Converts a [KacheSnapshot] into a Riverpod [AsyncValue].
///
/// The Kache snapshot already encodes the full SWR state: cached data can
/// coexist with [KacheSnapshot.isRefreshing] and [KacheSnapshot.hasFailure].
/// We map this to Riverpod's [AsyncValue] as follows:
///
/// - **Has data** → [AsyncValue.data]. This covers fresh data, stale data
///   being revalidated, and data that survived a refresh failure. The UI sees
///   the value and can optionally inspect [KacheSnapshot] directly for
///   refresh/failure status when richer detail is needed.
/// - **No data, loading** → [AsyncValue.loading].
/// - **No data, failure** → [AsyncValue.error].
///
/// The optional [previous] parameter lets callers carry forward the last good
/// value across a manual refresh that transitions through loading — this
/// avoids a flash of the loading indicator when cached data was already shown.
AsyncValue<T> snapshotToAsync<T>(
  KacheSnapshot<T> snapshot, {
  AsyncValue<T>? previous,
}) {
  // If we have visible data, always show it — even during refresh or with a
  // refresh failure (SWR semantics: stale data stays visible).
  if (snapshot.hasData) {
    return AsyncValue<T>.data(snapshot.requireData);
  }

  switch (snapshot.phase) {
    case KachePhase.idle:
    case KachePhase.loading:
      // If we had previous data, keep showing it instead of a loading spinner.
      if (previous != null && previous.hasValue) {
        return previous;
      }
      return AsyncValue<T>.loading();
    case KachePhase.ready:
      // hasData was false but phase is ready — shouldn't happen, but degrade
      // gracefully to loading.
      return AsyncValue<T>.loading();
    case KachePhase.failure:
      final failure = snapshot.failure;
      if (failure != null) {
        // If we still have previous data, prefer showing it over the error.
        if (previous != null && previous.hasValue) {
          return previous;
        }
        return AsyncValue<T>.error(failure.cause, failure.stackTrace);
      }
      return AsyncValue<T>.loading();
  }
}

/// Logs [KacheEvent]s in debug mode for observability.
void debugLogKacheEvent(KacheEvent event) {
  if (!kDebugMode) {
    return;
  }
  // Intentionally lightweight — no payload is logged.
  debugPrint('[Kache] ${event.kind.name}'
      '${event.key != null ? ' key=${event.key!.storageKey}' : ''}'
      '${event.namespace != null ? ' ns=${event.namespace!.value}' : ''}'
      '${event.failure != null ? ' failure=${event.failure!.kind.name}' : ''}');
}
