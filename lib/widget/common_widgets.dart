import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/screen.dart';

class CommonWidgets {
  static Widget sliverBottomSpace = SliverToBoxAdapter(
    child: SizedBox(
      height: Sz.navBarHeight + 64.0,
    ),
  );
}
