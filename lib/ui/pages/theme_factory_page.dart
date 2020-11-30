import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/model/theme_item.dart';
import 'package:mikan_flutter/providers/view_models/theme_factory_model.dart';
import 'package:mikan_flutter/providers/view_models/theme_list_model.dart';
import 'package:mikan_flutter/providers/view_models/theme_model.dart';
import 'package:mikan_flutter/widget/custom_switch.dart';
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
  final ThemeItem themeItem;

  const ThemeFactoryPage({Key key, this.themeListModel, this.themeItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThemeModel themeModel =
        Provider.of<ThemeModel>(context, listen: false);
    return AnnotatedRegion(
      value: context.fitSystemUiOverlayStyle,
      child: ChangeNotifierProvider(
        create: (_) =>
            ThemeFactoryModel(this.themeItem, themeModel, this.themeListModel),
        child: Scaffold(
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
                child: Consumer<ThemeFactoryModel>(
                  builder: (_, model, __) {
                    return _buildThemeFactoryWrapper(theme, model);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeFactoryWrapper(
    final ThemeData theme,
    final ThemeFactoryModel model,
  ) {
    final ThemeItem themeItem = model.themeItem;
    return Column(
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
            this.themeItem == null ? "创建主题" : "编辑主题",
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
            horizontal: 16.0,
          ),
          height: 50.0,
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
                  color: Color(themeItem.primaryColor),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        MaterialButton(
          onPressed: () {},
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          height: 50.0,
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
              Container(
                width: 24.0,
                height: 24.0,
                decoration: BoxDecoration(
                  color: Color(themeItem.accentColor),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        MaterialButton(
          onPressed: () {},
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          height: 50.0,
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
              Container(
                width: 24.0,
                height: 24.0,
                decoration: BoxDecoration(
                  color: Color(themeItem.lightScaffoldBackgroundColor),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        MaterialButton(
          onPressed: () {},
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          height: 50.0,
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
              Container(
                width: 24.0,
                height: 24.0,
                decoration: BoxDecoration(
                  color: Color(themeItem.lightBackgroundColor),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (themeItem.autoMode)
          MaterialButton(
            onPressed: () {},
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            height: 50.0,
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  "背景色 • 暗色",
                  style: TextStyle(
                    fontSize: 16.0,
                    height: 1.25,
                  ),
                )),
                Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    color: Color(themeItem.darkScaffoldBackgroundColor),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (themeItem.autoMode)
          MaterialButton(
            onPressed: () {},
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            height: 50.0,
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  "前景色 • 暗色",
                  style: TextStyle(
                    fontSize: 16.0,
                    height: 1.25,
                  ),
                )),
                Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    color: Color(themeItem.darkBackgroundColor),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        MaterialButton(
          onPressed: () {},
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          height: 50.0,
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
              CustomSwitch(
                value: themeItem.autoMode,
                activeColor: theme.accentColor,
                onChanged: (value) {
                  model.themeItem.autoMode = value;
                  model.notifyListeners();
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 12.0),
      ],
    );
  }
}
