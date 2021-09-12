import 'package:mikan_flutter/providers/base_model.dart';

class SettingsModel extends CancelableBaseModel {
  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (_hasScrolled != value) {
      _hasScrolled = value;
      notifyListeners();
    }
  }
}
