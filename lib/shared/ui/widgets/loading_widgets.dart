import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../res/assets.gen.dart';
import '../../widgets/scalable_tap.dart';
import '../../../topvars.dart';

class SliverLoadingWidget extends StatelessWidget {
  const SliverLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 180.0,
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SizedBox.expand(
          child: ScalableCard(onTap: () {}, child: centerLoading),
        ),
      ),
    );
  }
}

class SliverEmptyWidget extends StatelessWidget {
  const SliverEmptyWidget({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: ScalableCard(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  Assets.mikan.image(width: 64.0),
                  const Gap(12),
                  Text(text, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
