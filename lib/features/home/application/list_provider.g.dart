// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ListNotifier)
final listProvider = ListNotifierProvider._();

final class ListNotifierProvider extends $AsyncNotifierProvider<ListNotifier, ListData> {
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
}

String _$listNotifierHash() => r'ee0c990957a549d7cb6e09cd969cfd614ff5c2b7';

abstract class _$ListNotifier extends $AsyncNotifier<ListData> {
  FutureOr<ListData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ListData>, ListData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ListData>, ListData>,
              AsyncValue<ListData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
