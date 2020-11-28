import 'package:mikan_flutter/providers/view_models/base_model.dart';

class HomeModel extends BaseModel {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }
}
