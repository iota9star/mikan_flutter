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

String _$indexHash() => r'1d2cc49b4c959cde309e24f8592469cfe3f1c7d6';

abstract class _$Index extends $AsyncNotifier<IndexData> {
  FutureOr<IndexData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<IndexData>, IndexData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<IndexData>, IndexData>,
              AsyncValue<IndexData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Derived provider: 当前选中的季度
/// 从 indexProvider 中提取 selectedSeason

@ProviderFor(selectedSeason)
final selectedSeasonProvider = SelectedSeasonProvider._();

/// Derived provider: 当前选中的季度
/// 从 indexProvider 中提取 selectedSeason

final class SelectedSeasonProvider extends $FunctionalProvider<Season?, Season?, Season?> with $Provider<Season?> {
  /// Derived provider: 当前选中的季度
  /// 从 indexProvider 中提取 selectedSeason
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
  $ProviderElement<Season?> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Season? create(Ref ref) {
    return selectedSeason(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Season? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Season?>(value));
  }
}

String _$selectedSeasonHash() => r'e2bbe0bb0d936b226b07188d4403e17919b2b176';

/// Derived provider: 年份季度列表
/// 从 indexProvider 中提取 years

@ProviderFor(years)
final yearsProvider = YearsProvider._();

/// Derived provider: 年份季度列表
/// 从 indexProvider 中提取 years

final class YearsProvider extends $FunctionalProvider<List<YearSeason>, List<YearSeason>, List<YearSeason>>
    with $Provider<List<YearSeason>> {
  /// Derived provider: 年份季度列表
  /// 从 indexProvider 中提取 years
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
  $ProviderElement<List<YearSeason>> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  List<YearSeason> create(Ref ref) {
    return years(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<YearSeason> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<List<YearSeason>>(value));
  }
}

String _$yearsHash() => r'ebd10fa399cda98d3962546b2e87ab237711592b';
