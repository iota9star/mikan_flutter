import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/subgroup.dart';
import 'package:mikan_flutter/topvars.dart';

class SubgroupFragment extends StatelessWidget {
  final List<Subgroup> subgroups;

  const SubgroupFragment({Key? key, required this.subgroups}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: edgeHT16B8,
            child: Text("请选择字幕组"),
          ),
          ...List.generate(
            subgroups.length,
            (index) {
              final Subgroup subgroup = subgroups[index];
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.subgroup.name,
                    arguments: Routes.subgroup.d(subgroup: subgroup),
                  );
                },
                child: Container(
                  padding: edgeH16V8,
                  child: Row(
                    children: [
                      Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          borderRadius: borderRadius12,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primary,
                              theme.primary.withOpacity(0.56),
                            ],
                          ),
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
                          style: textStyle16B,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 8 + Screen.navBarHeight),
        ],
      ),
    );
  }
}
