import 'dart:core';

import 'package:flutter/cupertino.dart';

extension UIKit on BuildContext {
  MediaQueryData get mediaQueryData => MediaQuery.of(this);

  Size get screenSize => mediaQueryData.size;

  double get devicePixelRatio => mediaQueryData.devicePixelRatio;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  double get screenRatio => screenWidth / screenHeight;

  EdgeInsets get safePadding => mediaQueryData.padding;

  double get statusBarHeight => safePadding.top;

  double get navBarHeight => safePadding.bottom;

  bool get isHandset => screenWidth < 600.0;

  bool get isFoldableSmallTablet => screenWidth >= 600.0 && screenWidth < 840.0;

  bool get isLargeTablet => screenWidth >= 840.0;

  int get columns {
    if (isHandset) {
      return 4;
    }
    if (isFoldableSmallTablet) {
      return 12;
    }
    if (isLargeTablet) {
      return 12;
    }
    return 12;
  }

  double get margins {
    if (isHandset) {
      return 8.0;
    }
    if (isFoldableSmallTablet) {
      return 12.0;
    }
    if (isLargeTablet) {
      return 32.0;
    }
    return 32.0;
  }
}
