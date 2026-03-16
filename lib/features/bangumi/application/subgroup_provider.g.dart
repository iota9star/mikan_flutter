// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subgroup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(subgroupGalleries)
final subgroupGalleriesProvider = SubgroupGalleriesFamily._();

final class SubgroupGalleriesProvider
    extends $FunctionalProvider<AsyncValue<List<SeasonGallery>>, List<SeasonGallery>, FutureOr<List<SeasonGallery>>>
    with $FutureModifier<List<SeasonGallery>>, $FutureProvider<List<SeasonGallery>> {
  SubgroupGalleriesProvider._({required SubgroupGalleriesFamily super.from, required Subgroup super.argument})
    : super(
        retry: null,
        name: r'subgroupGalleriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subgroupGalleriesHash();

  @override
  String toString() {
    return r'subgroupGalleriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SeasonGallery>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<SeasonGallery>> create(Ref ref) {
    final argument = this.argument as Subgroup;
    return subgroupGalleries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SubgroupGalleriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$subgroupGalleriesHash() => r'6232b3b1815a1b6d07c2436fde535f832819b644';

final class SubgroupGalleriesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SeasonGallery>>, Subgroup> {
  SubgroupGalleriesFamily._()
    : super(
        retry: null,
        name: r'subgroupGalleriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SubgroupGalleriesProvider call(Subgroup subgroup) => SubgroupGalleriesProvider._(argument: subgroup, from: this);

  @override
  String toString() => r'subgroupGalleriesProvider';
}
