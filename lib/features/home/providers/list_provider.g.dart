// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ListNotifier)
final listProvider = ListNotifierProvider._();

final class ListNotifierProvider extends $NotifierProvider<ListNotifier, AsyncValue<ListData>> {
  ListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listNotifierHash();

  @$internal
  @override
  ListNotifier create() => ListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ListData> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AsyncValue<ListData>>(value));
  }
}

String _$listNotifierHash() => r'0d9debe9abb3abfde17dfb29f112d1344340eba1';

abstract class _$ListNotifier extends $Notifier<AsyncValue<ListData>> {
  AsyncValue<ListData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ListData>, AsyncValue<ListData>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ListData>, AsyncValue<ListData>>,
              AsyncValue<ListData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
