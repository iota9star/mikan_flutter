import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/screen.dart';

const edgeH16V8 = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
const edgeHT16 = const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0);
const edgeH16T4 = const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0);
const edgeH16T8 = const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0);
const edgeH16T8B16 =
    const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0);
const edgeHB16T8 =
    const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0);
const edgeHB24 = const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0);
const edgeH16T24B8 =
    const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 24.0);
const edge16 = const EdgeInsets.all(16.0);
const edge8 = const EdgeInsets.all(8.0);
const edge10 = const EdgeInsets.all(10.0);
const edge12 = const EdgeInsets.all(12.0);
const edge6 = const EdgeInsets.all(6.0);
const edge4 = const EdgeInsets.all(4.0);
const edge2 = const EdgeInsets.all(2.0);
const edgeV4 = const EdgeInsets.symmetric(vertical: 4.0);
const edgeV8 = const EdgeInsets.symmetric(vertical: 8.0);
const edge24 = const EdgeInsets.all(24.0);
const edge28 = const EdgeInsets.all(28.0);
const edgeH12V8 = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
const edgeH16 = const EdgeInsets.symmetric(horizontal: 16.0);
const edgeH24 = const EdgeInsets.symmetric(horizontal: 24.0);
const edgeH8 = const EdgeInsets.symmetric(horizontal: 8.0);
const edgeH4 = const EdgeInsets.symmetric(horizontal: 4.0);
const edgeH16V12 = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
const edgeH8V6 = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0);
const edgeT2 = const EdgeInsets.only(top: 2.0);
const edgeR4 = const EdgeInsets.only(right: 4.0);
const edgeR16 = const EdgeInsets.only(right: 16.0);
const edgeH4V2 = const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0);
const edgeRB4 = const EdgeInsets.only(right: 4.0, bottom: 4.0);
const edgeVT16R8 =
    const EdgeInsets.only(right: 8.0, left: 16.0, top: 16.0, bottom: 16.0);
const edgeHB16T4 =
    const EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0, bottom: 16.0);

const edgeHB16T24 =
    const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 16.0);

const edgeHT16B8 =
    const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16.0, right: 16.0);

const edgeT16B12 = const EdgeInsets.only(top: 16.0, bottom: 12.0);
const edgeB16 = const EdgeInsets.only(bottom: 16.0);
const edgeV8R12 = const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 12.0);

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

const borderRadiusT16 = const BorderRadius.only(
  topRight: radius16,
  topLeft: radius16,
);
const borderRadiusB16 = const BorderRadius.only(
  bottomLeft: radius16,
  bottomRight: radius16,
);

BorderRadius scrollHeaderBorderRadius(final bool hasScrolled) => hasScrolled
    ? BorderRadius.only(
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

const radius16 = const Radius.circular(16.0);
const radius10 = const Radius.circular(10.0);

const borderRadius24 = const BorderRadius.all(const Radius.circular(24.0));
const borderRadius16 = const BorderRadius.all(radius16);
const borderRadius12 = const BorderRadius.all(const Radius.circular(12.0));
const borderRadius10 = const BorderRadius.all(radius10);
const borderRadius8 = const BorderRadius.all(const Radius.circular(8.0));
const borderRadius2 = const BorderRadius.all(const Radius.circular(2.0));

const textStyle18B = const TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
  height: 1.25,
);

const textStyle14B500 = const TextStyle(
  fontSize: 14.0,
  height: 1.25,
  fontWeight: FontWeight.w500,
);
const textStyle15B500 = const TextStyle(
  fontSize: 15.0,
  height: 1.25,
  fontWeight: FontWeight.w500,
);
const textStyle14B = const TextStyle(
  fontSize: 14.0,
  height: 1.25,
  fontWeight: FontWeight.bold,
);
const textStyle15B = const TextStyle(
  fontSize: 15.0,
  height: 1.25,
  fontWeight: FontWeight.bold,
);
const textStyle16B = const TextStyle(
  fontSize: 16.0,
  height: 1.25,
  fontWeight: FontWeight.bold,
);

const textStyle16B500 = const TextStyle(
  fontSize: 16.0,
  height: 1.25,
  fontWeight: FontWeight.w500,
);

const textStyle16 = const TextStyle(
  fontSize: 16.0,
  height: 1.25,
);

const textStyle14 = const TextStyle(
  fontSize: 14.0,
  height: 1.25,
);

const textStyle13 = const TextStyle(
  fontSize: 13.0,
  height: 1.25,
);
const textStyle12 = const TextStyle(
  fontSize: 12.0,
  height: 1.25,
);
const textStyle13B500 = const TextStyle(
  fontSize: 13.0,
  height: 1.25,
  fontWeight: FontWeight.w500,
);

const textStyle24B = const TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.bold,
  height: 1.25,
);

const textStyle20B = const TextStyle(
  fontSize: 20.0,
  height: 1.25,
  fontWeight: FontWeight.bold,
);

TextStyle textStyle10WithColor(final Color color) => TextStyle(
      fontSize: 10,
      height: 1.25,
      color: color,
    );

const sizedBox = const SizedBox();
const sizedBoxW24 = const SizedBox(width: 24.0);
const sizedBoxW16 = const SizedBox(width: 16.0);
const sizedBoxH16 = const SizedBox(height: 16.0);
const sizedBoxW12 = const SizedBox(width: 12.0);
const sizedBoxH12 = const SizedBox(height: 12.0);
const sizedBoxH24 = const SizedBox(height: 24.0);
const sizedBoxH10 = const SizedBox(height: 10.0);
const sizedBoxH8 = const SizedBox(height: 8.0);
const sizedBoxW8 = const SizedBox(width: 8.0);
const sizedBoxW4 = const SizedBox(width: 4.0);
const sizedBoxH4 = const SizedBox(height: 4.0);
const sizedBoxH56 = const SizedBox(height: 56.0);
const sizedBoxH42 = const SizedBox(height: 42.0);

const sliverSizedBoxH80 = const SliverToBoxAdapter(
  child: const SizedBox(height: 80.0),
);

const spacer = const Spacer();

const dur240 = const Duration(milliseconds: 240);
const dur3000 = const Duration(milliseconds: 3000);

const emptySliverToBoxAdapter = const SliverToBoxAdapter();

const circleShape = const CircleBorder();

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
      children: <Widget>[
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

const centerLoading = const Center(child: CupertinoActivityIndicator());

const offsetY_1 = const Offset(0, -1);
const offsetY_2 = const Offset(0, -2);

final navKey = GlobalKey<NavigatorState>();
