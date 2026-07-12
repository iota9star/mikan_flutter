// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SeasonList)
final seasonListProvider = SeasonListFamily._();

final class SeasonListProvider
    extends $NotifierProvider<SeasonList, AsyncValue<SeasonListState>> {
  SeasonListProvider._({
    required SeasonListFamily super.from,
    required List<YearSeason> super.argument,
  }) : super(
         retry: null,
         name: r'seasonListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seasonListHash();

  @override
  String toString() {
    return r'seasonListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SeasonList create() => SeasonList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<SeasonListState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<SeasonListState>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SeasonListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seasonListHash() => r'4bd30045b0178979c3cbd017374c5e32ed722fd8';

final class SeasonListFamily extends $Family
    with
        $ClassFamilyOverride<
          SeasonList,
          AsyncValue<SeasonListState>,
          AsyncValue<SeasonListState>,
          AsyncValue<SeasonListState>,
          List<YearSeason>
        > {
  SeasonListFamily._()
    : super(
        retry: null,
        name: r'seasonListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SeasonListProvider call(List<YearSeason> years) =>
      SeasonListProvider._(argument: years, from: this);

  @override
  String toString() => r'seasonListProvider';
}

abstract class _$SeasonList extends $Notifier<AsyncValue<SeasonListState>> {
  late final _$args = ref.$arg as List<YearSeason>;
  List<YearSeason> get years => _$args;

  AsyncValue<SeasonListState> build(List<YearSeason> years);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<SeasonListState>, AsyncValue<SeasonListState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SeasonListState>,
                AsyncValue<SeasonListState>
              >,
              AsyncValue<SeasonListState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
