import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mikan_flutter/model/theme_item.dart';
import 'package:mikan_flutter/providers/theme_edit_model.dart';
import 'package:mikan_flutter/providers/theme_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:provider/provider.dart';

class ThemeEditFragment extends StatelessWidget {
  final ThemeItem? themeItem;

  const ThemeEditFragment({Key? key, this.themeItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => ThemeEditModel(this.themeItem, context.read<ThemeModel>()),
      child: Material(
        color: theme.scaffoldBackgroundColor,
        child: _buildThemeFactoryWrapper(theme),
      ),
    );
  }

  Widget _buildThemeFactoryWrapper(final ThemeData theme) {
    return Consumer<ThemeEditModel>(
      builder: (context, model, __) {
        final ThemeItem themeItem = model.themeItem;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, theme, model),
            const SizedBox(height: 12.0),
            MaterialButton(
              onPressed: () {},
              padding: EdgeInsets.only(
                left: 16.0,
                right: 8.0,
              ),
              height: 56.0,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "跟随系统",
                      style: TextStyle(
                        fontSize: 16.0,
                        height: 1.25,
                      ),
                    ),
                  ),
                  Switch(
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
            if (!themeItem.autoMode)
              MaterialButton(
                onPressed: () {},
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 8.0,
                ),
                height: 56.0,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "暗色模式",
                        style: TextStyle(
                          fontSize: 16.0,
                          height: 1.25,
                        ),
                      ),
                    ),
                    Switch(
                      value: themeItem.isDark,
                      activeColor: theme.accentColor,
                      onChanged: (value) {
                        model.themeItem.isDark = value;
                        model.notifyListeners();
                      },
                    ),
                  ],
                ),
              ),
            MaterialButton(
              onPressed: () {
                _showColorPicker(
                  context,
                  Color(themeItem.primaryColor),
                  (color) {
                    themeItem.primaryColor = color.value;
                    model.notifyListeners();
                  },
                );
              },
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              height: 56.0,
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
              onPressed: () {
                _showColorPicker(
                  context,
                  Color(themeItem.accentColor),
                  (color) {
                    themeItem.accentColor = color.value;
                    model.notifyListeners();
                  },
                );
              },
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              height: 56.0,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "强调色",
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
            if (themeItem.autoMode || !themeItem.isDark)
              MaterialButton(
                onPressed: () {
                  _showColorPicker(
                    context,
                    Color(themeItem.lightScaffoldBackgroundColor),
                    (color) {
                      themeItem.lightScaffoldBackgroundColor = color.value;
                      model.notifyListeners();
                    },
                  );
                },
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                height: 56.0,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "背景色",
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
            if (themeItem.autoMode || !themeItem.isDark)
              MaterialButton(
                onPressed: () {
                  _showColorPicker(
                    context,
                    Color(themeItem.lightBackgroundColor),
                    (color) {
                      themeItem.lightBackgroundColor = color.value;
                      model.notifyListeners();
                    },
                  );
                },
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                height: 56.0,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "前景色",
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
            if (themeItem.autoMode || themeItem.isDark)
              MaterialButton(
                onPressed: () {
                  _showColorPicker(
                    context,
                    Color(themeItem.darkScaffoldBackgroundColor),
                    (color) {
                      themeItem.darkScaffoldBackgroundColor = color.value;
                      model.notifyListeners();
                    },
                  );
                },
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                height: 56.0,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "背景色 暗色",
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
            if (themeItem.autoMode || themeItem.isDark)
              MaterialButton(
                onPressed: () {
                  _showColorPicker(
                    context,
                    Color(themeItem.darkBackgroundColor),
                    (color) {
                      themeItem.darkBackgroundColor = color.value;
                      model.notifyListeners();
                    },
                  );
                },
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                height: 56.0,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "前景色 暗色",
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
            SizedBox(
              height: 12.0,
            ),
          ],
        );
      },
    );
  }

  _showColorPicker(
    final BuildContext context,
    final Color color,
    final ValueChanged<Color> onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(0.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: SingleChildScrollView(
            // child: ColorPicker(
            //   pickerColor: color,
            //   onColorChanged: onColorChanged,
            //   colorPickerWidth: 300.0,
            //   pickerAreaHeightPercent: 0.7,
            //   enableAlpha: true,
            //   displayThumbColor: true,
            //   showLabel: true,
            //   paletteType: PaletteType.hsv,
            //   pickerAreaBorderRadius: const BorderRadius.only(
            //     topLeft: const Radius.circular(2.0),
            //     topRight: const Radius.circular(2.0),
            //   ),
            // ),
            child: SlidePicker(
              pickerColor: color,
              onColorChanged: onColorChanged,
              paletteType: PaletteType.rgb,
              enableAlpha: false,
              displayThumbColor: false,
              showLabel: false,
              showIndicator: true,
              indicatorBorderRadius: const BorderRadius.vertical(
                top: const Radius.circular(16.0),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    final BuildContext context,
    final ThemeData theme,
    final ThemeEditModel themeEditModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.024),
            offset: Offset(0, 1),
            blurRadius: 3.0,
            spreadRadius: 3.0,
          ),
        ],
        borderRadius: borderRadiusB16,
      ),
      padding: edge16,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "编辑主题",
              style: TextStyle(
                fontSize: 20,
                height: 1.25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              themeEditModel.apply(this.themeItem == null, () {
                Navigator.pop(context);
              });
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.all(8.0),
            child: Icon(
              FluentIcons.save_24_regular,
              size: 16.0,
            ),
            minWidth: 0,
            color: theme.scaffoldBackgroundColor,
            shape: CircleBorder(),
          ),
        ],
      ),
    );
  }
}
