import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class TransitionContainer extends StatelessWidget {
  const TransitionContainer({
    super.key,
    required this.next,
    required this.builder,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
    ),
    this.transitionType = ContainerTransitionType.fade,
    this.transitionDuration = const Duration(milliseconds: 360),
    this.closedColor,
  });

  final Widget next;
  final CloseContainerBuilder builder;
  final ShapeBorder shape;
  final ContainerTransitionType transitionType;
  final Duration transitionDuration;
  final Color? closedColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer(
      closedColor:
          closedColor ?? theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
      openColor: theme.scaffoldBackgroundColor,
      openElevation: 0.0,
      closedElevation: 0.0,
      closedShape: shape,
      transitionType: transitionType,
      transitionDuration: transitionDuration,
      openBuilder: (_, __) => next,
      tappable: false,
      closedBuilder: builder,
    );
  }
}
