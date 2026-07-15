// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_subscribed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Recent subscribed provider — paginated view over recent subscription data.
///
/// The initial load and [refresh] use `MikanApi.day(2)`, which is also cached
/// by [recentRecordsProvider] in the kache layer. Pagination ([loadMore])
/// fetches further days and is network-only by nature.

@ProviderFor(RecentSubscribed)
final recentSubscribedProvider = RecentSubscribedFamily._();

/// Recent subscribed provider — paginated view over recent subscription data.
///
/// The initial load and [refresh] use `MikanApi.day(2)`, which is also cached
/// by [recentRecordsProvider] in the kache layer. Pagination ([loadMore])
/// fetches further days and is network-only by nature.
final class RecentSubscribedProvider
    extends $AsyncNotifierProvider<RecentSubscribed, RecentSubscribedState> {
  /// Recent subscribed provider — paginated view over recent subscription data.
  ///
  /// The initial load and [refresh] use `MikanApi.day(2)`, which is also cached
  /// by [recentRecordsProvider] in the kache layer. Pagination ([loadMore])
  /// fetches further days and is network-only by nature.
  RecentSubscribedProvider._({
    required RecentSubscribedFamily super.from,
    required List<RecordItem> super.argument,
  }) : super(
         retry: null,
         name: r'recentSubscribedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentSubscribedHash();

  @override
  String toString() {
    return r'recentSubscribedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RecentSubscribed create() => RecentSubscribed();

  @override
  bool operator ==(Object other) {
    return other is RecentSubscribedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentSubscribedHash() => r'd9c18140ef3524dda102e90f0970d2861a60c6b8';

/// Recent subscribed provider — paginated view over recent subscription data.
///
/// The initial load and [refresh] use `MikanApi.day(2)`, which is also cached
/// by [recentRecordsProvider] in the kache layer. Pagination ([loadMore])
/// fetches further days and is network-only by nature.

final class RecentSubscribedFamily extends $Family
    with
        $ClassFamilyOverride<
          RecentSubscribed,
          AsyncValue<RecentSubscribedState>,
          RecentSubscribedState,
          FutureOr<RecentSubscribedState>,
          List<RecordItem>
        > {
  RecentSubscribedFamily._()
    : super(
        retry: null,
        name: r'recentSubscribedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Recent subscribed provider — paginated view over recent subscription data.
  ///
  /// The initial load and [refresh] use `MikanApi.day(2)`, which is also cached
  /// by [recentRecordsProvider] in the kache layer. Pagination ([loadMore])
  /// fetches further days and is network-only by nature.

  RecentSubscribedProvider call(List<RecordItem> records) =>
      RecentSubscribedProvider._(argument: records, from: this);

  @override
  String toString() => r'recentSubscribedProvider';
}

/// Recent subscribed provider — paginated view over recent subscription data.
///
/// The initial load and [refresh] use `MikanApi.day(2)`, which is also cached
/// by [recentRecordsProvider] in the kache layer. Pagination ([loadMore])
/// fetches further days and is network-only by nature.

abstract class _$RecentSubscribed
    extends $AsyncNotifier<RecentSubscribedState> {
  late final _$args = ref.$arg as List<RecordItem>;
  List<RecordItem> get records => _$args;

  FutureOr<RecentSubscribedState> build(List<RecordItem> records);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<RecentSubscribedState>, RecentSubscribedState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RecentSubscribedState>,
                RecentSubscribedState
              >,
              AsyncValue<RecentSubscribedState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
