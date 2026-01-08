// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 季度番剧数据
/// 返回指定季度的番剧列表

@ProviderFor(season)
final seasonProvider = SeasonFamily._();

/// 季度番剧数据
/// 返回指定季度的番剧列表

final class SeasonProvider extends $FunctionalProvider<AsyncValue<SeasonData>, SeasonData, FutureOr<SeasonData>>
    with $FutureModifier<SeasonData>, $FutureProvider<SeasonData> {
  /// 季度番剧数据
  /// 返回指定季度的番剧列表
  SeasonProvider._({required SeasonFamily super.from, required model.Season super.argument})
    : super(
        retry: null,
        name: r'seasonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seasonHash();

  @override
  String toString() {
    return r'seasonProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SeasonData> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<SeasonData> create(Ref ref) {
    final argument = this.argument as model.Season;
    return season(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SeasonProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seasonHash() => r'e33694fa6629a712e6e851770c84d9ff80e8d399';

/// 季度番剧数据
/// 返回指定季度的番剧列表

final class SeasonFamily extends $Family with $FunctionalFamilyOverride<FutureOr<SeasonData>, model.Season> {
  SeasonFamily._()
    : super(
        retry: null,
        name: r'seasonProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 季度番剧数据
  /// 返回指定季度的番剧列表

  SeasonProvider call(model.Season seasonParam) => SeasonProvider._(argument: seasonParam, from: this);

  @override
  String toString() => r'seasonProvider';
}
