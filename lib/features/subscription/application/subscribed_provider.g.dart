// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rssRecords)
final rssRecordsProvider = RssRecordsProvider._();

final class RssRecordsProvider
    extends
        $FunctionalProvider<Map<String, List<RecordItem>>, Map<String, List<RecordItem>>, Map<String, List<RecordItem>>>
    with $Provider<Map<String, List<RecordItem>>> {
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

String _$rssRecordsHash() => r'7d7d8f0f56516a0f4cdd5bac03eebbc135976d99';
