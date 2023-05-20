import '../internal/hive.dart';
import 'base_model.dart';

class SettingsModel extends BaseModel {
  SettingsModel() {
    refreshCacheSize();
  }

  String _formatCacheSize = '';

  String get formatCacheSize => _formatCacheSize;

  void refreshCacheSize() {
    MyHive.getFormatCacheSize().then((value) {
      _formatCacheSize = value;
      notifyListeners();
    });
  }
}
