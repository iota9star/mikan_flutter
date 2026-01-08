// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 搜索关键字（用户输入状态）

@ProviderFor(SearchKeywords)
final searchKeywordsProvider = SearchKeywordsProvider._();

/// 搜索关键字（用户输入状态）
final class SearchKeywordsProvider extends $NotifierProvider<SearchKeywords, String?> {
  /// 搜索关键字（用户输入状态）
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
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String?>(value));
  }
}

String _$searchKeywordsHash() => r'39491f299b40c4c244bdfe4847c392f97b18e3fc';

/// 搜索关键字（用户输入状态）

abstract class _$SearchKeywords extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<String?, String?>, String?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// 选中的字幕组ID（筛选状态）

@ProviderFor(SearchSubgroupId)
final searchSubgroupIdProvider = SearchSubgroupIdProvider._();

/// 选中的字幕组ID（筛选状态）
final class SearchSubgroupIdProvider extends $NotifierProvider<SearchSubgroupId, String?> {
  /// 选中的字幕组ID（筛选状态）
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
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String?>(value));
  }
}

String _$searchSubgroupIdHash() => r'9de54b85dc5f049bd2b55924805102101bdb735f';

/// 选中的字幕组ID（筛选状态）

abstract class _$SearchSubgroupId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<String?, String?>, String?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// 搜索结果（AsyncValue 自动处理 loading/data/error 状态）

@ProviderFor(search)
final searchProvider = SearchProvider._();

/// 搜索结果（AsyncValue 自动处理 loading/data/error 状态）

final class SearchProvider extends $FunctionalProvider<AsyncValue<SearchResult>, SearchResult, FutureOr<SearchResult>>
    with $FutureModifier<SearchResult>, $FutureProvider<SearchResult> {
  /// 搜索结果（AsyncValue 自动处理 loading/data/error 状态）
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
  $FutureProviderElement<SearchResult> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<SearchResult> create(Ref ref) {
    return search(ref);
  }
}

String _$searchHash() => r'5ae1c1900479e41d8c3e6583ec6132cf18ae2bf7';
