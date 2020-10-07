import 'package:oktoast/oktoast.dart';

extension IterableExt<T> on Iterable<T> {
  bool get isNullOrEmpty => this == null || this.isEmpty;

  bool get isNotEmpty => !this.isNullOrEmpty;

  T getOrNull(final int index) => this?.elementAt(index);
}

extension MapExt<K, V> on Map<K, V> {
  bool get isNullOrEmpty => this == null || this.isEmpty;

  bool get isNotEmpty => !this.isNullOrEmpty;

  V getOrNull(K key) => this == null ? null : this[key];
}

extension StringExt on String {
  bool get isNullOrBlank => this == null || this.isEmpty;

  bool get isNotBlank => !this.isNullOrBlank;

  toast() async {
    if (this.isNotBlank) {
      showToast(this);
    }
  }
}
