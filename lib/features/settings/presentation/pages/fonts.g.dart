// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fonts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Fonts)
final fontsProvider = FontsProvider._();

final class FontsProvider extends $NotifierProvider<Fonts, FontsState> {
  FontsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fontsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fontsHash();

  @$internal
  @override
  Fonts create() => Fonts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FontsState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<FontsState>(value));
  }
}

String _$fontsHash() => r'008b7297d8001e1d11905dfccde6e2044322f636';

abstract class _$Fonts extends $Notifier<FontsState> {
  FontsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FontsState, FontsState>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<FontsState, FontsState>, FontsState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(fontProgress)
final fontProgressProvider = FontProgressFamily._();

final class FontProgressProvider
    extends $FunctionalProvider<ProgressChunkEvent?, ProgressChunkEvent?, ProgressChunkEvent?>
    with $Provider<ProgressChunkEvent?> {
  FontProgressProvider._({required FontProgressFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'fontProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fontProgressHash();

  @override
  String toString() {
    return r'fontProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ProgressChunkEvent?> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ProgressChunkEvent? create(Ref ref) {
    final argument = this.argument as String;
    return fontProgress(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgressChunkEvent? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ProgressChunkEvent?>(value));
  }

  @override
  bool operator ==(Object other) {
    return other is FontProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fontProgressHash() => r'02ef3df2aade14778cc9948e609783b3ca41fecb';

final class FontProgressFamily extends $Family with $FunctionalFamilyOverride<ProgressChunkEvent?, String> {
  FontProgressFamily._()
    : super(
        retry: null,
        name: r'fontProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FontProgressProvider call(String fontId) => FontProgressProvider._(argument: fontId, from: this);

  @override
  String toString() => r'fontProgressProvider';
}

@ProviderFor(usedFontFamilyId)
final usedFontFamilyIdProvider = UsedFontFamilyIdProvider._();

final class UsedFontFamilyIdProvider extends $FunctionalProvider<String?, String?, String?> with $Provider<String?> {
  UsedFontFamilyIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usedFontFamilyIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usedFontFamilyIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return usedFontFamilyId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String?>(value));
  }
}

String _$usedFontFamilyIdHash() => r'4e1099b362bb3584789e409059fea2789a2adc13';
