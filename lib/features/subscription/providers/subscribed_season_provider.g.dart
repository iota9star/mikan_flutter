// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribed_season_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubscribedSeason)
final subscribedSeasonProvider = SubscribedSeasonFamily._();

final class SubscribedSeasonProvider extends $NotifierProvider<SubscribedSeason, SubscribedSeasonState> {
  SubscribedSeasonProvider._({
    required SubscribedSeasonFamily super.from,
    required (List<YearSeason>, List<SeasonGallery>) super.argument,
  }) : super(
         retry: null,
         name: r'subscribedSeasonProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$subscribedSeasonHash();

  @override
  String toString() {
    return r'subscribedSeasonProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SubscribedSeason create() => SubscribedSeason();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscribedSeasonState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<SubscribedSeasonState>(value));
  }

  @override
  bool operator ==(Object other) {
    return other is SubscribedSeasonProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$subscribedSeasonHash() => r'c7e508779a62d530292d3878ec4cf87a1380acf2';

final class SubscribedSeasonFamily extends $Family
    with
        $ClassFamilyOverride<
          SubscribedSeason,
          SubscribedSeasonState,
          SubscribedSeasonState,
          SubscribedSeasonState,
          (List<YearSeason>, List<SeasonGallery>)
        > {
  SubscribedSeasonFamily._()
    : super(
        retry: null,
        name: r'subscribedSeasonProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SubscribedSeasonProvider call(List<YearSeason> years, List<SeasonGallery> galleries) =>
      SubscribedSeasonProvider._(argument: (years, galleries), from: this);

  @override
  String toString() => r'subscribedSeasonProvider';
}

abstract class _$SubscribedSeason extends $Notifier<SubscribedSeasonState> {
  late final _$args = ref.$arg as (List<YearSeason>, List<SeasonGallery>);
  List<YearSeason> get years => _$args.$1;
  List<SeasonGallery> get galleries => _$args.$2;

  SubscribedSeasonState build(List<YearSeason> years, List<SeasonGallery> galleries);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SubscribedSeasonState, SubscribedSeasonState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SubscribedSeasonState, SubscribedSeasonState>,
              SubscribedSeasonState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
