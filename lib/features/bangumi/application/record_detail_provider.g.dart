// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recordDetail)
final recordDetailProvider = RecordDetailFamily._();

final class RecordDetailProvider
    extends $FunctionalProvider<AsyncValue<RecordDetail>, RecordDetail, FutureOr<RecordDetail>>
    with $FutureModifier<RecordDetail>, $FutureProvider<RecordDetail> {
  RecordDetailProvider._({required RecordDetailFamily super.from, required RecordItem super.argument})
    : super(
        retry: null,
        name: r'recordDetailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordDetailHash();

  @override
  String toString() {
    return r'recordDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RecordDetail> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<RecordDetail> create(Ref ref) {
    final argument = this.argument as RecordItem;
    return recordDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecordDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recordDetailHash() => r'cddf484c0f53bce67471f1f78f327cd5abd324d3';

final class RecordDetailFamily extends $Family with $FunctionalFamilyOverride<FutureOr<RecordDetail>, RecordItem> {
  RecordDetailFamily._()
    : super(
        retry: null,
        name: r'recordDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecordDetailProvider call(RecordItem record) => RecordDetailProvider._(argument: record, from: this);

  @override
  String toString() => r'recordDetailProvider';
}
