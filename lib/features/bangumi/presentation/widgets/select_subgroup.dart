import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:mikan/app/routing/mikan_routes.dart';
import 'package:mikan/core/models/subgroup.dart';
import 'package:mikan/core/widgets/ripple_tap.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';

class SelectSubgroup extends StatelessWidget {
  const SelectSubgroup({super.key, required this.subgroups});

  final List<Subgroup> subgroups;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverPinnedAppBar(title: '请选择字幕组'),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final sub = subgroups[index];
              return RippleTap(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(child: Text(sub.name[0])),
                      const Gap(16),
                      Text(sub.name, style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, Routes.subgroup.name, arguments: Routes.subgroup.d(subgroup: sub));
                },
              );
            }, childCount: subgroups.length),
          ),
        ],
      ),
    );
  }
}
