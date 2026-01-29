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
final class RecentSubscribedProvider extends $AsyncNotifierProvider<RecentSubscribed, RecentSubscribedState> {
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

  @override
  bool operator ==(Object other) {
    return other is RecentSubscribedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentSubscribedHash() => r'3a68f72b66236e99834b6c937645c7f21306f119';

/// Recent subscribed provider - manages subscription data with AsyncValue

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

  /// Recent subscribed provider - manages subscription data with AsyncValue

  RecentSubscribedProvider call(List<RecordItem> records) => RecentSubscribedProvider._(argument: records, from: this);

  @override
  String toString() => r'recentSubscribedProvider';
}

/// Recent subscribed provider - manages subscription data with AsyncValue

abstract class _$RecentSubscribed extends $AsyncNotifier<RecentSubscribedState> {
  late final _$args = ref.$arg as List<RecordItem>;
  List<RecordItem> get records => _$args;

  FutureOr<RecentSubscribedState> build(List<RecordItem> records);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<RecentSubscribedState>, RecentSubscribedState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RecentSubscribedState>, RecentSubscribedState>,
              AsyncValue<RecentSubscribedState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
