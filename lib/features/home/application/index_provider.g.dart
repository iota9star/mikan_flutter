// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Index)
final indexProvider = IndexProvider._();

final class IndexProvider extends $AsyncNotifierProvider<Index, IndexData> {
  IndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'indexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$indexHash();

  @$internal
  @override
  Index create() => Index();
}

String _$indexHash() => r'86670858f33d154ce0ff9040103d40432808d19a';

abstract class _$Index extends $AsyncNotifier<IndexData> {
  FutureOr<IndexData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<IndexData>, IndexData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<IndexData>, IndexData>,
              AsyncValue<IndexData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(selectedSeason)
final selectedSeasonProvider = SelectedSeasonProvider._();

final class SelectedSeasonProvider
    extends $FunctionalProvider<Season?, Season?, Season?>
    with $Provider<Season?> {
  SelectedSeasonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedSeasonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedSeasonHash();

  @$internal
  @override
  $ProviderElement<Season?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Season? create(Ref ref) {
    return selectedSeason(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Season? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Season?>(value),
    );
  }
}

String _$selectedSeasonHash() => r'92fc08f3c6f8e24e218be4c80ea1a686164d7f5f';

@ProviderFor(years)
final yearsProvider = YearsProvider._();

final class YearsProvider
    extends
        $FunctionalProvider<
          List<YearSeason>,
          List<YearSeason>,
          List<YearSeason>
        >
    with $Provider<List<YearSeason>> {
  YearsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'yearsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$yearsHash();

  @$internal
  @override
  $ProviderElement<List<YearSeason>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<YearSeason> create(Ref ref) {
    return years(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<YearSeason> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<YearSeason>>(value),
    );
  }
}

String _$yearsHash() => r'f6c5da42f5c5f5d525ed8308f3beb1471ab2759e';
