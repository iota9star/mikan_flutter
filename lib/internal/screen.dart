import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:mikan_flutter/internal/extension.dart';

class Sz {
  static final MediaQueryData mediaQueryData =
      MediaQueryData.fromWindow(window);
  static final Size screenPhysicalSize = window.physicalSize;
  static final double screenPhysicalWidth = screenPhysicalSize.width;
  static final double screenPhysicalHeight = screenPhysicalSize.height;
  static final Size screenSize = mediaQueryData.size;
  static final double devicePixelRatio = mediaQueryData.devicePixelRatio;
  static final double screenWidth = screenSize.width;
  static final double screenHeight = screenSize.height;
  static final double screenRatio = screenWidth / screenHeight;
  static final EdgeInsets safePadding = mediaQueryData.padding;
  static final double statusBarHeight = safePadding.top;
  static final double navBarHeight = safePadding.bottom;
  static final bool isTablet = screenSize.shortestSide >= 600;

  const Sz._();

  static void screenInfo() {
    "screen info."
            "\n===========================================>"
            "\nscreenPhysicalSize: $screenPhysicalSize, "
            "\nscreenPhysicalWidth: $screenPhysicalWidth, "
            "\nscreenPhysicalHeight: $screenPhysicalHeight, "
            "\nscreenSize: $screenSize, "
            "\nscreenWidth: $screenWidth, "
            "\nscreenHeight: $screenHeight, "
            "\nscreenRatio: $screenRatio, "
            "\ndevicePixelRatio: $devicePixelRatio, "
            "\nmediaQueryData: $mediaQueryData, "
            "\nsafePadding: $safePadding, "
            "\nstatusBarHeight: $statusBarHeight, "
            "\nnavBarHeight: $navBarHeight, "
            "\nisTablet: $isTablet, "
            "\n<==========================================="
        .debug();
  }
}
