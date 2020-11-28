import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Store {
  Store._();

  static Directory cacheDir;
  static Directory docDir;
  static Directory filesDir;

  static init() async {
    cacheDir = await getTemporaryDirectory();
    docDir = await getApplicationDocumentsDirectory();
    filesDir = await getApplicationSupportDirectory();
  }
}
