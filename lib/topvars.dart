import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide EdgeInsets;
import 'package:gap/gap.dart';

import 'internal/kit.dart';
import 'widget/md3e_header.dart';

EdgeInsets edge16WithStatusBar(BuildContext context) =>
    EdgeInsets.only(top: 16.0 + context.statusBarHeight, left: 16.0, right: 16.0, bottom: 16.0);

EdgeInsets edgeH24V36WithStatusBar(BuildContext context) =>
    EdgeInsets.only(top: context.statusBarHeight + 36.0, bottom: 36.0, left: 24.0, right: 24.0);

EdgeInsets edgeH16T96B48WithSafeHeight(BuildContext context) =>
    EdgeInsets.only(top: 96.0 + context.statusBarHeight, left: 16.0, right: 16.0, bottom: 48.0 + context.navBarHeight);

EdgeInsets edgeHT16B24WithNavbarHeight(BuildContext context) =>
    EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 24.0 + context.navBarHeight);

EdgeInsets edgeH16B24WithNavbarHeight(BuildContext context) =>
    EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0 + context.navBarHeight);

BorderRadius scrollHeaderBorderRadius(bool hasScrolled) => hasScrolled
    ? const BorderRadius.only(bottomLeft: Radius.circular(16.0), bottomRight: Radius.circular(16.0))
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

Widget sliverGapH130WithNavBarHeight(BuildContext context) =>
    SliverToBoxAdapter(child: Gap(130.0 + context.navBarHeight));

Widget gapH24WithNavBarHeight(BuildContext context) => Gap(24.0 + context.navBarHeight);

Widget sliverGapH24WithNavBarHeight(BuildContext context) =>
    SliverToBoxAdapter(child: Gap(24.0 + context.navBarHeight));

const spacer = Spacer();

const dur240 = Duration(milliseconds: 240);
const dur3000 = Duration(milliseconds: 3000);

const emptySliverToBoxAdapter = SliverToBoxAdapter();

const centerLoading = Center(
  child: ExpressiveLoadingIndicator(
    constraints: BoxConstraints.tightFor(width: 24, height: 24),
  ),
);

double kMaterialHeaderFactorFactor(double overscrollFraction) => 2.0 * math.pow(1 - overscrollFraction, 2);

const defaultHeader = Md3eHeader();

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
