import 'package:riverpod/riverpod.dart';

/// Extension to combine two AsyncValues
extension AsyncValueCombine<T1, T2> on (AsyncValue<T1>, AsyncValue<T2>) {
  R whenAll<R>({
    required R Function(T1 d1, T2 d2) data,
    required R Function() loading,
    required R Function(Object error, StackTrace stackTrace) error,
  }) {
    return $1.when(
      data: (d1) => $2.when(data: (d2) => data(d1, d2), loading: loading, error: error),
      loading: loading,
      error: error,
    );
  }
}

/// Extension to combine three AsyncValues
extension AsyncValueCombine3<T1, T2, T3> on (AsyncValue<T1>, AsyncValue<T2>, AsyncValue<T3>) {
  R whenAll<R>({
    required R Function(T1 d1, T2 d2, T3 d3) data,
    required R Function() loading,
    required R Function(Object error, StackTrace stackTrace) error,
  }) {
    return $1.when(
      data: (d1) => $2.when(
        data: (d2) => $3.when(data: (d3) => data(d1, d2, d3), loading: loading, error: error),
        loading: loading,
        error: error,
      ),
      loading: loading,
      error: error,
    );
  }
}
