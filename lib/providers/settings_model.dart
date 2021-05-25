import 'package:mikan_flutter/providers/base_model.dart';

class SettingsModel extends CancelableBaseModel {
  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (this._hasScrolled != value) {
      this._hasScrolled = value;
      notifyListeners();
    }
  }
}
