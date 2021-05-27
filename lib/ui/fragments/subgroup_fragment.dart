import 'package:flutter/material.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/subgroup.dart';

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
          Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 8.0,
              left: 16.0,
              right: 16.0,
            ),
            child: const Text("请选择字幕组"),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24.0,
                        height: 24.0,
                        child: Center(
                          child: Text(
                            subgroups[index].name[0],
                            style: TextStyle(
                              fontSize: 12.0,
                              height: 1.25,
                              color: theme.primaryColor.computeLuminance() < 0.5
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withOpacity(0.56),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      Expanded(
                        child: Text(
                          subgroup.name,
                          style: TextStyle(
                            height: 1.25,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(
            height: 8.0,
          )
        ],
      ),
    );
  }
}
