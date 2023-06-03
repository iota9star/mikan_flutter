import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../internal/extension.dart';
import '../internal/kit.dart';
import '../topvars.dart';
import 'icon_button.dart';

class SliverPinnedAppBar extends StatelessWidget {
  const SliverPinnedAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.autoImplLeading = true,
    this.borderRadius,
    this.minExtent,
    this.maxExtent,
    this.startPadding,
    this.endPadding,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool autoImplLeading;
  final BorderRadius? borderRadius;
  final double? minExtent;
  final double? maxExtent;
  final double? startPadding;
  final double? endPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appbarHeight = minExtent ?? 64.0;
    final statusBarHeight = context.statusBarHeight;
    final maxHeight = statusBarHeight + (maxExtent ?? 160.0);
    final minHeight = statusBarHeight + appbarHeight;
    final offsetHeight = maxHeight - minHeight;
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final hasLeading = leading != null || (autoImplLeading && canPop);
    final lp = startPadding ?? (hasLeading ? 12.0 : 24.0);
    final rp =
        endPadding ?? (actions != null && actions!.isNotEmpty ? 12.0 : 24.0);
    return SliverPersistentHeader(
      delegate: WrapSliverPersistentHeaderDelegate(
        maxExtent: maxHeight,
        minExtent: minHeight,
        onBuild: (
          BuildContext context,
          double shrinkOffset,
          bool overlapsContent,
        ) {
          final offsetRatio = math.min(shrinkOffset / offsetHeight, 1.0);
          final display = offsetRatio >= 0.99;
          final children = [
            if (leading != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                child: leading,
              )
            else if (autoImplLeading && canPop)
              const Padding(
                padding: EdgeInsetsDirectional.only(end: 12.0),
                child: BackIconButton(),
              ),
            if (display)
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Spacer(),
          ];
          if (!actions.isNullOrEmpty) {
            children.add(sizedBoxW12);
            children.addAll(actions!);
          }
          return Stack(
            children: [
              Positioned(
                bottom: 12.0,
                left: 24.0,
                right: 24.0,
                child: Text(
                  title,
                  style: theme.textTheme.headlineMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                top: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: borderRadius,
                  ),
                  padding: EdgeInsetsDirectional.only(
                    start: lp,
                    end: rp,
                    top: statusBarHeight,
                  ),
                  height: statusBarHeight + appbarHeight,
                  child: Row(
                    children: children,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      pinned: true,
    );
  }
}

class StackSliverPinnedHeader extends StatelessWidget {
  const StackSliverPinnedHeader({
    super.key,
    required this.childrenBuilder,
    this.maxExtent,
    this.minExtent,
  });

  final List<Widget> Function(
    BuildContext context,
    double ratio,
    double shrinkOffset,
  ) childrenBuilder;
  final double? maxExtent;
  final double? minExtent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = maxExtent ?? context.statusBarHeight + 136.0;
    final minHeight = minExtent ?? context.statusBarHeight + 60.0;
    final offsetHeight = maxHeight - minHeight;
    return SliverPersistentHeader(
      delegate: WrapSliverPersistentHeaderDelegate(
        maxExtent: maxHeight,
        minExtent: minHeight,
        onBuild: (
          BuildContext context,
          double shrinkOffset,
          bool overlapsContent,
        ) {
          final offsetRatio = math.min(shrinkOffset / offsetHeight, 1.0);
          return DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              border: Border(
                bottom: BorderSide(
                  color: offsetRatio >= 0.99
                      ? theme.colorScheme.surfaceVariant
                      : Colors.transparent,
                ),
              ),
            ),
            child: Stack(
              children: childrenBuilder(context, offsetRatio, shrinkOffset),
            ),
          );
        },
      ),
      pinned: true,
    );
  }
}

class WrapSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  WrapSliverPersistentHeaderDelegate({
    required this.maxExtent,
    required this.minExtent,
    required this.onBuild,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return onBuild(context, shrinkOffset, overlapsContent);
  }

  @override
  final double maxExtent;
  @override
  final double minExtent;
  final Function(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) onBuild;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
