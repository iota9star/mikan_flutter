import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';

class SubgroupFragment extends StatelessWidget {
  final List<Subgroup> subgroups;

  const SubgroupFragment({Key? key, required this.subgroups}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: edge16,
            decoration: BoxDecoration(color: theme.colorScheme.background),
            child: const Text(
              "请选择字幕组",
              style: textStyle18B,
            ),
          ),
          ...List.generate(
            subgroups.length,
            (index) {
              final Subgroup subgroup = subgroups[index];
              return RippleTap(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.subgroup.name,
                    arguments: Routes.subgroup.d(subgroup: subgroup),
                  );
                },
                child: Padding(
                  padding: edge16,
                  child: Row(
                    children: [
                      Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          borderRadius: borderRadius16,
                          color: theme.primary,
                        ),
                        child: Center(
                          child: Text(
                            subgroups[index].name[0],
                            style: TextStyle(
                              fontSize: 12.0,
                              height: 1.25,
                              color: theme.primary.isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      sizedBoxW12,
                      Expanded(
                        child: Text(
                          subgroup.name,
                          maxLines: 1,
                          style: textStyle15B,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 8 + Screens.navBarHeight),
        ],
      ),
    );
  }
}
