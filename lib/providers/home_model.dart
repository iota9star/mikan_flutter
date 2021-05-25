import 'package:mikan_flutter/providers/base_model.dart';

class HomeModel extends BaseModel {
  /// default select home page.
  int _selectedIndex = 1;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }
}
