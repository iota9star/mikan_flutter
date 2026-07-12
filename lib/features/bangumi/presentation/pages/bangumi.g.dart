// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bangumi.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Bangumi)
final bangumiProvider = BangumiFamily._();

final class BangumiProvider extends $NotifierProvider<Bangumi, BangumiState> {
  BangumiProvider._({
    required BangumiFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'bangumiProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bangumiHash();

  @override
  String toString() {
    return r'bangumiProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  Bangumi create() => Bangumi();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BangumiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BangumiState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BangumiProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bangumiHash() => r'a22f4fc0559e10fd0ba0eade4acdcd985518aac5';

final class BangumiFamily extends $Family
    with
        $ClassFamilyOverride<
          Bangumi,
          BangumiState,
          BangumiState,
          BangumiState,
          (String, String)
        > {
  BangumiFamily._()
    : super(
        retry: null,
        name: r'bangumiProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BangumiProvider call(String id, String cover) =>
      BangumiProvider._(argument: (id, cover), from: this);

  @override
  String toString() => r'bangumiProvider';
}

abstract class _$Bangumi extends $Notifier<BangumiState> {
  late final _$args = ref.$arg as (String, String);
  String get id => _$args.$1;
  String get cover => _$args.$2;

  BangumiState build(String id, String cover);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BangumiState, BangumiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BangumiState, BangumiState>,
              BangumiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
