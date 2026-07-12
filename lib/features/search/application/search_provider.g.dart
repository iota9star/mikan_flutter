// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchKeywords)
final searchKeywordsProvider = SearchKeywordsProvider._();

final class SearchKeywordsProvider
    extends $NotifierProvider<SearchKeywords, String?> {
  SearchKeywordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchKeywordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchKeywordsHash();

  @$internal
  @override
  SearchKeywords create() => SearchKeywords();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$searchKeywordsHash() => r'39491f299b40c4c244bdfe4847c392f97b18e3fc';

abstract class _$SearchKeywords extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchSubgroupId)
final searchSubgroupIdProvider = SearchSubgroupIdProvider._();

final class SearchSubgroupIdProvider
    extends $NotifierProvider<SearchSubgroupId, String?> {
  SearchSubgroupIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchSubgroupIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchSubgroupIdHash();

  @$internal
  @override
  SearchSubgroupId create() => SearchSubgroupId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$searchSubgroupIdHash() => r'9de54b85dc5f049bd2b55924805102101bdb735f';

abstract class _$SearchSubgroupId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(search)
final searchProvider = SearchProvider._();

final class SearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<SearchResult>,
          SearchResult,
          FutureOr<SearchResult>
        >
    with $FutureModifier<SearchResult>, $FutureProvider<SearchResult> {
  SearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHash();

  @$internal
  @override
  $FutureProviderElement<SearchResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SearchResult> create(Ref ref) {
    return search(ref);
  }
}

String _$searchHash() => r'bdb5c8f0c84d009b4f00caa25cc93189be53bcf6';
