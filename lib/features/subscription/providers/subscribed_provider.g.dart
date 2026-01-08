// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 订阅的番剧列表（按季度）
/// 当 selectedSeason 变化时自动重新加载

@ProviderFor(subscribedBangumis)
final subscribedBangumisProvider = SubscribedBangumisFamily._();

/// 订阅的番剧列表（按季度）
/// 当 selectedSeason 变化时自动重新加载

final class SubscribedBangumisProvider
    extends $FunctionalProvider<AsyncValue<List<Bangumi>>, List<Bangumi>, FutureOr<List<Bangumi>>>
    with $FutureModifier<List<Bangumi>>, $FutureProvider<List<Bangumi>> {
  /// 订阅的番剧列表（按季度）
  /// 当 selectedSeason 变化时自动重新加载
  SubscribedBangumisProvider._({required SubscribedBangumisFamily super.from, required Season? super.argument})
    : super(
        retry: null,
        name: r'subscribedBangumisProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscribedBangumisHash();

  @override
  String toString() {
    return r'subscribedBangumisProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Bangumi>> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Bangumi>> create(Ref ref) {
    final argument = this.argument as Season?;
    return subscribedBangumis(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SubscribedBangumisProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$subscribedBangumisHash() => r'834477419ee0b723b0e471c222add25f26efc7d8';

/// 订阅的番剧列表（按季度）
/// 当 selectedSeason 变化时自动重新加载

final class SubscribedBangumisFamily extends $Family with $FunctionalFamilyOverride<FutureOr<List<Bangumi>>, Season?> {
  SubscribedBangumisFamily._()
    : super(
        retry: null,
        name: r'subscribedBangumisProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 订阅的番剧列表（按季度）
  /// 当 selectedSeason 变化时自动重新加载

  SubscribedBangumisProvider call(Season? season) => SubscribedBangumisProvider._(argument: season, from: this);

  @override
  String toString() => r'subscribedBangumisProvider';
}

/// 最近的订阅记录（最近2天）

@ProviderFor(recentRecords)
final recentRecordsProvider = RecentRecordsProvider._();

/// 最近的订阅记录（最近2天）

final class RecentRecordsProvider
    extends $FunctionalProvider<AsyncValue<List<RecordItem>>, List<RecordItem>, FutureOr<List<RecordItem>>>
    with $FutureModifier<List<RecordItem>>, $FutureProvider<List<RecordItem>> {
  /// 最近的订阅记录（最近2天）
  RecentRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentRecordsHash();

  @$internal
  @override
  $FutureProviderElement<List<RecordItem>> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RecordItem>> create(Ref ref) {
    return recentRecords(ref);
  }
}

String _$recentRecordsHash() => r'eca0f321ec36130c0bc91a168bba5f8b534cb93c';

/// RSS 分组的记录（derived from recentRecords）

@ProviderFor(rssRecords)
final rssRecordsProvider = RssRecordsProvider._();

/// RSS 分组的记录（derived from recentRecords）

final class RssRecordsProvider
    extends
        $FunctionalProvider<Map<String, List<RecordItem>>, Map<String, List<RecordItem>>, Map<String, List<RecordItem>>>
    with $Provider<Map<String, List<RecordItem>>> {
  /// RSS 分组的记录（derived from recentRecords）
  RssRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rssRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rssRecordsHash();

  @$internal
  @override
  $ProviderElement<Map<String, List<RecordItem>>> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Map<String, List<RecordItem>> create(Ref ref) {
    return rssRecords(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<RecordItem>> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Map<String, List<RecordItem>>>(value));
  }
}

String _$rssRecordsHash() => r'516d3a4d8461dbc859b3ad032310515a6c446a96';
