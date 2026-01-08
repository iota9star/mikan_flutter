// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_subscribed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Recent subscribed provider - manages subscription data with AsyncValue

@ProviderFor(RecentSubscribed)
final recentSubscribedProvider = RecentSubscribedFamily._();

/// Recent subscribed provider - manages subscription data with AsyncValue
final class RecentSubscribedProvider extends $NotifierProvider<RecentSubscribed, AsyncValue<RecentSubscribedState>> {
  /// Recent subscribed provider - manages subscription data with AsyncValue
  RecentSubscribedProvider._({required RecentSubscribedFamily super.from, required List<RecordItem> super.argument})
    : super(
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RecentSubscribedState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<RecentSubscribedState>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecentSubscribedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentSubscribedHash() => r'2578f127b8fe0769cb5a6a66e061582938da97db';

/// Recent subscribed provider - manages subscription data with AsyncValue

final class RecentSubscribedFamily extends $Family
    with
        $ClassFamilyOverride<
          RecentSubscribed,
          AsyncValue<RecentSubscribedState>,
          AsyncValue<RecentSubscribedState>,
          AsyncValue<RecentSubscribedState>,
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

  /// Recent subscribed provider - manages subscription data with AsyncValue

  RecentSubscribedProvider call(List<RecordItem> records) => RecentSubscribedProvider._(argument: records, from: this);

  @override
  String toString() => r'recentSubscribedProvider';
}

/// Recent subscribed provider - manages subscription data with AsyncValue

abstract class _$RecentSubscribed extends $Notifier<AsyncValue<RecentSubscribedState>> {
  late final _$args = ref.$arg as List<RecordItem>;
  List<RecordItem> get records => _$args;

  AsyncValue<RecentSubscribedState> build(List<RecordItem> records);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<RecentSubscribedState>, AsyncValue<RecentSubscribedState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RecentSubscribedState>, AsyncValue<RecentSubscribedState>>,
              AsyncValue<RecentSubscribedState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
