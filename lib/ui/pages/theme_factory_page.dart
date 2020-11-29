import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/providers/view_models/theme_factory_model.dart';
import 'package:mikan_flutter/providers/view_models/theme_list_model.dart';
import 'package:provider/provider.dart';

@FFRoute(
  name: "theme-factory",
  routeName: "theme-factory",
  argumentImports: [
    "import 'package:mikan_flutter/providers/view_models/theme_list_model.dart;",
    "import 'package:flutter/material.dart';",
  ],
)
@immutable
class ThemeFactoryPage extends StatelessWidget {
  final ThemeListModel themeListModel;

  const ThemeFactoryPage({Key key, this.themeListModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) => ThemeFactoryModel(this.themeListModel),
        child: Builder(builder: (context) {
          final ThemeFactoryModel themeFactoryModel =
              Provider.of(context, listen: false);
          return Scaffold(
            body: Column(
              children: [
                Expanded(child: Container()),
                Container(
                  margin: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0 + Sz.navBarHeight,
                  ),
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: 24.0,
                          bottom: 12.0,
                        ),
                        child: Text(
                          "编辑主题",
                          style: TextStyle(
                            fontSize: 14.0,
                            height: 1.25,
                            color: theme.accentColor,
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {},
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "主色调",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            Container(
                              width: 24.0,
                              height: 24.0,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {},
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              "强调色",
                              style: TextStyle(
                                fontSize: 16.0,
                                height: 1.25,
                              ),
                            )),
                            Container(),
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {},
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              "背景色",
                              style: TextStyle(
                                fontSize: 16.0,
                                height: 1.25,
                              ),
                            )),
                            Container(),
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {},
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              "前景色",
                              style: TextStyle(
                                fontSize: 16.0,
                                height: 1.25,
                              ),
                            )),
                            Container(),
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {},
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              "背景色 暗色模式",
                              style: TextStyle(
                                fontSize: 16.0,
                                height: 1.25,
                              ),
                            )),
                            Container(),
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {},
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              "前景色 暗色模式",
                              style: TextStyle(
                                fontSize: 16.0,
                                height: 1.25,
                              ),
                            )),
                            Container(),
                          ],
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {},
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              "跟随系统",
                              style: TextStyle(
                                fontSize: 16.0,
                                height: 1.25,
                              ),
                            )),
                            Container(),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.0),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
