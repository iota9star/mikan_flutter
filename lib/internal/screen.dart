import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:mikan_flutter/internal/logger.dart';

class Sz {
  static MediaQueryData _mediaQueryData = MediaQueryData.fromWindow(window);
  static Size _screenPhysicalSize = window.physicalSize;
  static double _screenPhysicalWidth = _screenPhysicalSize.width;
  static double _screenPhysicalHeight = _screenPhysicalSize.height;
  static Size _screenSize = _mediaQueryData.size;
  static double _devicePixelRatio = _mediaQueryData.devicePixelRatio;
  static double _screenWidth = _screenSize.width;
  static double _screenHeight = _screenSize.height;
  static double _screenRatio = _screenWidth / _screenHeight;
  static EdgeInsets _safePadding = _mediaQueryData.padding;
  static double _statusBarHeight = _safePadding.top;
  static double _navBarHeight = _safePadding.bottom;
  static bool _isTablet = _screenSize.shortestSide >= 600;

  static double get devicePixelRatio => _devicePixelRatio;

  static Size get screenSize => _screenSize;

  static double get screenWidth => _screenWidth;

  static double get screenHeight => _screenHeight;

  static double get screenRatio => _screenRatio;

  static MediaQueryData get mediaQueryData => _mediaQueryData;

  static EdgeInsets get safePadding => _safePadding;

  static double get statusBarHeight => _statusBarHeight;

  static double get navBarHeight => _navBarHeight;

  static bool get isTablet => _isTablet;

  static Size get screenPhysicalSize => _screenPhysicalSize;

  static double get screenPhysicalWidth => _screenPhysicalWidth;

  static double get screenPhysicalHeight => _screenPhysicalHeight;

  const Sz._();

  static void screenInfo() {
    logd("screen info."
        "\n===========================================>"
        "\n_screenPhysicalSize: $_screenPhysicalSize, "
        "\n_screenPhysicalWidth: $_screenPhysicalWidth, "
        "\n_screenPhysicalHeight: $_screenPhysicalHeight, "
        "\n_screenSize: $_screenSize, "
        "\n_screenWidth: $_screenWidth, "
        "\n_screenHeight: $_screenHeight, "
        "\n_screenRatio: $_screenRatio, "
        "\n_devicePixelRatio: $_devicePixelRatio, "
        "\n_mediaQueryData: $_mediaQueryData, "
        "\n_safePadding: $_safePadding, "
        "\n_statusBarHeight: $_statusBarHeight, "
        "\n_navBarHeight: $_navBarHeight, "
        "\n_isTablet: $_isTablet, "
        "\n<===========================================");
  }
}
