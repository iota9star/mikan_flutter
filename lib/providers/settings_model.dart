import 'package:mikan_flutter/internal/store.dart';
import 'package:mikan_flutter/providers/base_model.dart';

class SettingsModel extends CancelableBaseModel {
  SettingsModel() {
    refreshCacheSize();
  }

  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (_hasScrolled != value) {
      _hasScrolled = value;
      notifyListeners();
    }
  }

  String _formatCacheSize = '';

  String get formatCacheSize => _formatCacheSize;

  void refreshCacheSize() {
    Store.getFormatCacheSize().then((value) {
      _formatCacheSize = value;
      notifyListeners();
    });
  }
}
