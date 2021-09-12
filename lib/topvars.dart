import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';

const edgeH16V4 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0);
const edgeH16V8 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
const edgeHT16 = EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0);
const edgeH16T4 = EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0);
const edgeH16T8 = EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0);
const edgeH16T8B16 =
    EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0);
const edgeHB16T8 =
    EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0);
const edgeHB24 = EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0);
const edgeL16R8 = EdgeInsets.only(left: 16.0, right: 8.0);
const edgeH16T24B8 =
    EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 24.0);
const edge16 = EdgeInsets.all(16.0);
const edge8 = EdgeInsets.all(8.0);
const edge10 = EdgeInsets.all(10.0);
const edge12 = EdgeInsets.all(12.0);
const edge6 = EdgeInsets.all(6.0);
const edge4 = EdgeInsets.all(4.0);
const edge2 = EdgeInsets.all(2.0);
const edgeV4 = EdgeInsets.symmetric(vertical: 4.0);
const edgeV8 = EdgeInsets.symmetric(vertical: 8.0);
const edge24 = EdgeInsets.all(24.0);
const edge28 = EdgeInsets.all(28.0);
const edgeH12V8 = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
const edgeH16 = EdgeInsets.symmetric(horizontal: 16.0);
const edgeH24 = EdgeInsets.symmetric(horizontal: 24.0);
const edgeH8 = EdgeInsets.symmetric(horizontal: 8.0);
const edgeH4 = EdgeInsets.symmetric(horizontal: 4.0);
const edgeH16V12 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
const edgeH8V6 = EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0);
const edgeT2 = EdgeInsets.only(top: 2.0);
const edgeR4 = EdgeInsets.only(right: 4.0);
const edgeR16 = EdgeInsets.only(right: 16.0);
const edgeH4V2 = EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0);
const edgeRB4 = EdgeInsets.only(right: 4.0, bottom: 4.0);
const edgeVT16R8 =
    EdgeInsets.only(right: 8.0, left: 16.0, top: 16.0, bottom: 16.0);
const edgeHB16T4 =
    EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0, bottom: 16.0);

const edgeHB16T24 =
    EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 16.0);

const edgeHT16B8 =
    EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16.0, right: 16.0);

const edgeT16B12 = EdgeInsets.only(top: 16.0, bottom: 12.0);
const edgeB16 = EdgeInsets.only(bottom: 16.0);
const edgeV8R12 = EdgeInsets.only(top: 8.0, bottom: 8.0, right: 12.0);

final edge16WithStatusBar = EdgeInsets.only(
  top: 16.0 + Screen.statusBarHeight,
  left: 16.0,
  right: 16.0,
  bottom: 16.0,
);

final edgeH24V36WithStatusBar = EdgeInsets.only(
  top: Screen.statusBarHeight + 36.0,
  bottom: 36.0,
  left: 24.0,
  right: 24.0,
);

final edgeH16T90B24WithStatusBar = EdgeInsets.only(
  top: 90.0 + Screen.statusBarHeight,
  left: 16.0,
  right: 16.0,
  bottom: 24.0,
);

final edgeHT16B24WithNavbarHeight = EdgeInsets.only(
  top: 16.0,
  left: 16.0,
  right: 16.0,
  bottom: 24.0 + Screen.navBarHeight,
);

final edgeH16B24WithNavbarHeight = EdgeInsets.only(
  left: 16.0,
  right: 16.0,
  bottom: 24.0 + Screen.navBarHeight,
);

const borderRadiusT16 = BorderRadius.only(
  topRight: radius16,
  topLeft: radius16,
);
const borderRadiusB16 = BorderRadius.only(
  bottomLeft: radius16,
  bottomRight: radius16,
);

BorderRadius scrollHeaderBorderRadius(final bool hasScrolled) => hasScrolled
    ? const BorderRadius.only(
        bottomLeft: radius16,
        bottomRight: radius16,
      )
    : BorderRadius.zero;

List<BoxShadow> scrollHeaderBoxShadow(final bool hasScrolled) => hasScrolled
    ? [
        BoxShadow(
          color: Colors.black.withOpacity(0.024),
          offset: const Offset(0, 1),
          blurRadius: 3.0,
          spreadRadius: 3.0,
        ),
      ]
    : const [];

const radius16 = Radius.circular(16.0);
const radius10 = Radius.circular(10.0);

const borderRadius24 = BorderRadius.all(Radius.circular(24.0));
const borderRadius16 = BorderRadius.all(radius16);
const borderRadius12 = BorderRadius.all(Radius.circular(12.0));
const borderRadius10 = BorderRadius.all(radius10);
const borderRadius8 = BorderRadius.all(Radius.circular(8.0));
const borderRadius2 = BorderRadius.all(Radius.circular(2.0));

const textStyle18B = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
  height: 1.25,
);

const textStyle14B500 = TextStyle(
  fontSize: 14.0,
  height: 1.25,
  fontWeight: FontWeight.w500,
);
const textStyle15B500 = TextStyle(
  fontSize: 15.0,
  height: 1.25,
  fontWeight: FontWeight.w500,
);
const textStyle14B = TextStyle(
  fontSize: 14.0,
  height: 1.25,
  fontWeight: FontWeight.bold,
);
const textStyle15B = TextStyle(
  fontSize: 15.0,
  height: 1.25,
  fontWeight: FontWeight.bold,
);
const textStyle16B = TextStyle(
  fontSize: 16.0,
  height: 1.25,
  fontWeight: FontWeight.bold,
);

const textStyle16B500 = TextStyle(
  fontSize: 16.0,
  height: 1.25,
  fontWeight: FontWeight.w500,
);

const textStyle16 = TextStyle(
  fontSize: 16.0,
  height: 1.25,
);

const textStyle14 = TextStyle(
  fontSize: 14.0,
  height: 1.25,
);

const textStyle13 = TextStyle(
  fontSize: 13.0,
  height: 1.25,
);

const textStyle12 = TextStyle(
  fontSize: 12.0,
  height: 1.25,
);

const textStyle10 = TextStyle(
  fontSize: 10.0,
  height: 1.25,
);

const textStyle13B500 = TextStyle(
  fontSize: 13.0,
  height: 1.25,
  fontWeight: FontWeight.w500,
);

const textStyle24B = TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.bold,
  height: 1.25,
);

const textStyle20B = TextStyle(
  fontSize: 20.0,
  height: 1.25,
  fontWeight: FontWeight.bold,
);

TextStyle textStyle10WithColor(final Color color) => TextStyle(
      fontSize: 10,
      height: 1.25,
      color: color,
    );

const sizedBox = SizedBox.shrink();
const sizedBoxW24 = SizedBox(width: 24.0);
const sizedBoxW16 = SizedBox(width: 16.0);
const sizedBoxH16 = SizedBox(height: 16.0);
const sizedBoxW12 = SizedBox(width: 12.0);
const sizedBoxH12 = SizedBox(height: 12.0);
const sizedBoxH24 = SizedBox(height: 24.0);
const sizedBoxH10 = SizedBox(height: 10.0);
const sizedBoxH8 = SizedBox(height: 8.0);
const sizedBoxW8 = SizedBox(width: 8.0);
const sizedBoxW4 = SizedBox(width: 4.0);
const sizedBoxH4 = SizedBox(height: 4.0);
const sizedBoxH56 = SizedBox(height: 56.0);
const sizedBoxH42 = SizedBox(height: 42.0);

final sliverSizedBoxH80 = SliverToBoxAdapter(
  child: SizedBox(height: 80.0 + Screen.navBarHeight),
);

final sliverSizedBoxH24 = SliverToBoxAdapter(
  child: SizedBox(height: 24.0 + Screen.navBarHeight),
);

const spacer = Spacer();

const dur240 = Duration(milliseconds: 240);
const dur3000 = Duration(milliseconds: 3000);

const emptySliverToBoxAdapter = SliverToBoxAdapter();

const circleShape = CircleBorder();

final normalFormHeader = Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <Widget>[
    ExtendedImage.asset(
      "assets/mikan.png",
      width: 72.0,
    ),
    sizedBoxW24,
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text(
          "Mikan Project",
          style: TextStyle(fontSize: 14.0),
        ),
        Text(
          "蜜柑计划",
          style: TextStyle(
            fontSize: 32.0,
            height: 1.25,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    )
  ],
);

const centerLoading = Center(child: CupertinoActivityIndicator());

const offsetY_1 = Offset(0, -1);
const offsetY_2 = Offset(0, -2);

final navKey = GlobalKey<NavigatorState>();

final controlButtonColors = [
  HexColor.fromHex("#fbb43a"),
  HexColor.fromHex("#3ec544"),
  HexColor.fromHex("#fa625c")
];
const controlButtonIcons = [
  FluentIcons.subtract_24_regular,
  FluentIcons.add_24_regular,
  FluentIcons.dismiss_24_regular
];
const controlButtonTooltips = ["最小化", "最大化", "关闭"];
final controlButtonActions = [
  () => appWindow.minimize(),
  () => appWindow.maximizeOrRestore(),
  () => appWindow.close(),
];

final normalScrollBehavior = const ScrollBehavior().copyWith(
  scrollbars: false,
  dragDevices: {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
  },
  physics: const BouncingScrollPhysics(),
  platform: TargetPlatform.iOS,
);
