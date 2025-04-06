import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'internal/kit.dart';

const edgeH16V4 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0);
const edgeH16V8 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
const edgeH24T16 = EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0);
const edgeH24T8 = EdgeInsets.only(left: 24.0, right: 24.0, top: 8.0);
const edgeH24V8 = EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0);
const edgeHT16 = EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0);
const edgeH16T4 = EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0);
const edgeH16T8 = EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0);
const edgeH16B16 = EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0);
const edgeH24B16 = EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0);
const edgeH16B8 = EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0);
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
const edgeH6V4 = EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0);
const edge2 = EdgeInsets.all(2.0);
const edgeV4 = EdgeInsets.symmetric(vertical: 4.0);
const edgeV8 = EdgeInsets.symmetric(vertical: 8.0);
const edgeV16 = EdgeInsets.symmetric(vertical: 16.0);
const edge24 = EdgeInsets.all(24.0);
const edge28 = EdgeInsets.all(28.0);
const edgeH12V8 = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
const edgeH16 = EdgeInsets.symmetric(horizontal: 16.0);
const edgeH24 = EdgeInsets.symmetric(horizontal: 24.0);
const edgeS24E12 = EdgeInsetsDirectional.only(start: 24.0, end: 12.0);
const edgeH24V16 = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
const edgeH8 = EdgeInsets.symmetric(horizontal: 8.0);
const edgeH4 = EdgeInsets.symmetric(horizontal: 4.0);
const edgeH16V12 = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
const edgeH24V12 = EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
const edgeH8V6 = EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0);
const edgeT2 = EdgeInsets.only(top: 2.0);
const edgeR4 = EdgeInsets.only(right: 4.0);
const edgeR16 = EdgeInsets.only(right: 16.0);
const edgeH4V2 = EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0);
const edgeH6V2 = EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0);
const edgeRB4 = EdgeInsets.only(right: 4.0, bottom: 4.0);
const edgeVT16R8 =
    EdgeInsets.only(right: 8.0, left: 16.0, top: 16.0, bottom: 16.0);
const edgeHB16T4 =
    EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0, bottom: 16.0);
const edgeH24B16T4 =
    EdgeInsets.only(top: 4.0, left: 24.0, right: 24.0, bottom: 16.0);

const edgeHB16T24 =
    EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 16.0);

const edgeHT16B8 =
    EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16.0, right: 16.0);

const edgeT16B12 = EdgeInsets.only(top: 16.0, bottom: 12.0);
const edgeB16 = EdgeInsets.only(bottom: 16.0);
const edgeV8R12 = EdgeInsets.only(top: 8.0, bottom: 8.0, right: 12.0);

EdgeInsets edge16WithStatusBar(BuildContext context) => EdgeInsets.only(
      top: 16.0 + context.statusBarHeight,
      left: 16.0,
      right: 16.0,
      bottom: 16.0,
    );

EdgeInsets edgeH24V36WithStatusBar(BuildContext context) => EdgeInsets.only(
      top: context.statusBarHeight + 36.0,
      bottom: 36.0,
      left: 24.0,
      right: 24.0,
    );

EdgeInsets edgeH16T96B48WithSafeHeight(BuildContext context) => EdgeInsets.only(
      top: 96.0 + context.statusBarHeight,
      left: 16.0,
      right: 16.0,
      bottom: 48.0 + context.navBarHeight,
    );

EdgeInsets edgeHT16B24WithNavbarHeight(BuildContext context) => EdgeInsets.only(
      top: 16.0,
      left: 16.0,
      right: 16.0,
      bottom: 24.0 + context.navBarHeight,
    );

EdgeInsets edgeH16B24WithNavbarHeight(BuildContext context) => EdgeInsets.only(
      left: 16.0,
      right: 16.0,
      bottom: 24.0 + context.navBarHeight,
    );

const borderRadiusT16 = BorderRadius.vertical(
  top: radius16,
);

const borderRadiusT28 = BorderRadius.vertical(
  top: radius28,
);

const borderRadiusB16 = BorderRadius.only(
  bottomLeft: radius16,
  bottomRight: radius16,
);

BorderRadius scrollHeaderBorderRadius(bool hasScrolled) => hasScrolled
    ? const BorderRadius.only(
        bottomLeft: radius16,
        bottomRight: radius16,
      )
    : BorderRadius.zero;

List<BoxShadow> scrollHeaderBoxShadow(bool hasScrolled) => hasScrolled
    ? [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.024),
          offset: const Offset(0, 1),
          blurRadius: 3.0,
          spreadRadius: 3.0,
        ),
      ]
    : const [];

const radius16 = Radius.circular(16.0);
const radius28 = Radius.circular(28.0);
const radius10 = Radius.circular(10.0);
const radius0 = Radius.zero;

const borderRadius24 = BorderRadius.all(Radius.circular(24.0));
const borderRadius16 = BorderRadius.all(radius16);
const borderRadius12 = BorderRadius.all(Radius.circular(12.0));
const borderRadius28 = BorderRadius.all(Radius.circular(28.0));
const borderRadiusVT28 = BorderRadius.vertical(top: Radius.circular(28.0));
const borderRadius10 = BorderRadius.all(radius10);
const borderRadius2 = BorderRadius.all(Radius.circular(2.0));
const borderRadius4 = BorderRadius.all(Radius.circular(4.0));
const borderRadius6 = BorderRadius.all(Radius.circular(6.0));
const borderRadius0 = BorderRadius.zero;
const borderRadiusCircle = BorderRadius.all(Radius.circular(9999999.0));
const borderRadiusBottom16 = BorderRadius.vertical(bottom: radius16);

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

Widget sliverSizedBoxH80WithNavBarHeight(BuildContext context) =>
    SliverToBoxAdapter(
      child: SizedBox(height: 80.0 + context.navBarHeight),
    );

Widget sizedBoxH24WithNavBarHeight(BuildContext context) =>
    SizedBox(height: 24.0 + context.navBarHeight);

Widget sliverSizedBoxH24WithNavBarHeight(BuildContext context) =>
    SliverToBoxAdapter(
      child: SizedBox(height: 24.0 + context.navBarHeight),
    );

const spacer = Spacer();

const dur240 = Duration(milliseconds: 240);
const dur3000 = Duration(milliseconds: 3000);

const emptySliverToBoxAdapter = SliverToBoxAdapter();

const centerLoading = Center(child: CupertinoActivityIndicator());

double kMaterialHeaderFactorFactor(double overscrollFraction) =>
    2.0 * math.pow(1 - overscrollFraction, 2);

const defaultHeader = MaterialHeader(
  triggerOffset: 180.0,
  hapticFeedback: true,
  frictionFactor: kMaterialHeaderFactorFactor,
);

Footer defaultFooter(BuildContext context) {
  final theme = Theme.of(context);
  return ClassicFooter(
    hapticFeedback: true,
    noMoreText: '没啦。。。',
    dragText: '使点劲，没吃饭吗？',
    armedText: '赶紧松手，遭不住了',
    readyText: '快了，快了',
    processingText: '马上粗来，别慌',
    processedText: '哦了，哦了',
    failedText: '失败了，再接再励',
    textStyle: theme.textTheme.titleMedium,
    showMessage: false,
  );
}

const offsetY_1 = Offset(0, -1);
const offsetY_2 = Offset(0, -2);

final navKey = GlobalKey<NavigatorState>();
