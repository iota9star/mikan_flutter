import 'package:flutter/material.dart';

import '../../mikan_routes.dart';
import '../../model/subgroup.dart';
import '../../topvars.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/sliver_pinned_header.dart';

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
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final sub = subgroups[index];
                return RippleTap(
                  child: Padding(
                    padding: edgeH24V12,
                    child: Row(
                      children: [
                        CircleAvatar(
                          child: Text(sub.name[0]),
                        ),
                        sizedBoxW16,
                        Text(
                          sub.name,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.subgroup.name,
                      arguments: Routes.subgroup.d(subgroup: sub),
                    );
                  },
                );
              },
              childCount: subgroups.length,
            ),
          ),
        ],
      ),
    );
  }
}
