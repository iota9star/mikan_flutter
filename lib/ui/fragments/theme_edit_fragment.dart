import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/model/theme_item.dart';
import 'package:mikan_flutter/providers/theme_edit_model.dart';
import 'package:mikan_flutter/providers/theme_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/icon_button.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';
import 'package:provider/provider.dart';

class ThemeEditFragment extends StatelessWidget {
  final ThemeItem? themeItem;

  const ThemeEditFragment({Key? key, this.themeItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => ThemeEditModel(themeItem, context.read<ThemeModel>()),
      child: Material(
        color: theme.colorScheme.background,
        child: _buildThemeFactoryWrapper(theme),
      ),
    );
  }

  Widget _buildThemeFactoryWrapper(final ThemeData theme) {
    return Consumer<ThemeEditModel>(
      builder: (context, model, __) {
        final themeItem = model.themeItem;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, theme, model),
            Container(
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
              child: Column(
                children: [
                  SizedBox(
                    height: 60.0,
                    child: Padding(
                      padding: edgeH16,
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "跟随系统",
                              style: textStyle16,
                            ),
                          ),
                          Switch(
                            value: themeItem.autoMode,
                            activeColor: theme.secondary,
                            onChanged: (value) {
                              model.themeItem.autoMode = value;
                              model.notifyListeners();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!themeItem.autoMode)
                    SizedBox(
                      height: 60.0,
                      child: Padding(
                        padding: edgeH16,
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "暗色模式",
                                style: textStyle16,
                              ),
                            ),
                            Switch(
                              value: themeItem.isDark,
                              activeColor: theme.secondary,
                              onChanged: (value) {
                                model.themeItem.isDark = value;
                                model.notifyListeners();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  RippleTap(
                    onTap: () {
                      _showColorPicker(
                        context,
                        theme,
                        Color(themeItem.primaryColor),
                        (color) {
                          themeItem.primaryColor = color.value;
                          model.notifyListeners();
                        },
                      );
                    },
                    child: SizedBox(
                      height: 60.0,
                      child: Padding(
                        padding: edgeH16,
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "主色调",
                                style: textStyle16,
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
                    ),
                  ),
                  RippleTap(
                    onTap: () {
                      _showColorPicker(
                        context,
                        theme,
                        Color(themeItem.accentColor),
                        (color) {
                          themeItem.accentColor = color.value;
                          model.notifyListeners();
                        },
                      );
                    },
                    child: SizedBox(
                      height: 60.0,
                      child: Padding(
                        padding: edgeH16,
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "强调色",
                                style: textStyle16,
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
                    ),
                  ),
                  if (themeItem.autoMode || !themeItem.isDark)
                    RippleTap(
                      onTap: () {
                        _showColorPicker(
                          context,
                          theme,
                          Color(themeItem.lightScaffoldBackgroundColor),
                          (color) {
                            themeItem.lightScaffoldBackgroundColor =
                                color.value;
                            model.notifyListeners();
                          },
                        );
                      },
                      child: SizedBox(
                        height: 60.0,
                        child: Padding(
                          padding: edgeH16,
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "背景色",
                                  style: textStyle16,
                                ),
                              ),
                              Container(
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  color: Color(
                                      themeItem.lightScaffoldBackgroundColor),
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
                      ),
                    ),
                  if (themeItem.autoMode || !themeItem.isDark)
                    RippleTap(
                      onTap: () {
                        _showColorPicker(
                          context,
                          theme,
                          Color(themeItem.lightBackgroundColor),
                          (color) {
                            themeItem.lightBackgroundColor = color.value;
                            model.notifyListeners();
                          },
                        );
                      },
                      child: SizedBox(
                        height: 60.0,
                        child: Padding(
                          padding: edgeH16,
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "前景色",
                                  style: textStyle16,
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
                      ),
                    ),
                  if (themeItem.autoMode || themeItem.isDark)
                    RippleTap(
                      onTap: () {
                        _showColorPicker(
                          context,
                          theme,
                          Color(themeItem.darkScaffoldBackgroundColor),
                          (color) {
                            themeItem.darkScaffoldBackgroundColor = color.value;
                            model.notifyListeners();
                          },
                        );
                      },
                      child: SizedBox(
                        height: 60.0,
                        child: Padding(
                          padding: edgeH16,
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "背景色 暗色",
                                  style: textStyle16,
                                ),
                              ),
                              Container(
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  color: Color(
                                      themeItem.darkScaffoldBackgroundColor),
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
                      ),
                    ),
                  if (themeItem.autoMode || themeItem.isDark)
                    RippleTap(
                      onTap: () {
                        _showColorPicker(
                          context,
                          theme,
                          Color(themeItem.darkBackgroundColor),
                          (color) {
                            themeItem.darkBackgroundColor = color.value;
                            model.notifyListeners();
                          },
                        );
                      },
                      child: SizedBox(
                        height: 60.0,
                        child: Padding(
                          padding: edgeH16,
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "前景色 暗色",
                                  style: textStyle16,
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
                      ),
                    ),
                  sizedBoxH24WithNavBarHeight,
                ],
              ),
            )
          ],
        );
      },
    );
  }

  _showColorPicker(
    final BuildContext context,
    final ThemeData theme,
    final Color color,
    final ValueChanged<Color> onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: borderRadius16,
          ),
          backgroundColor: theme.colorScheme.background,
          content: SingleChildScrollView(
            child: ColorPicker(
              color: color,
              onColorChangeEnd: onColorChanged,
              pickersEnabled: const {
                ColorPickerType.primary: true,
                ColorPickerType.accent: true,
                ColorPickerType.bw: true,
                ColorPickerType.wheel: true,
              },
              pickerTypeLabels: const {
                ColorPickerType.primary: "主色调",
                ColorPickerType.accent: "强调色",
                ColorPickerType.bw: "黑&白",
                ColorPickerType.wheel: "自定义",
              },
              pickerTypeTextStyle: textStyle15B500,
              selectedPickerTypeColor: theme.scaffoldBackgroundColor,
              enableOpacity: true,
              title: const Text(
                "请选择",
                style: textStyle20B,
              ),
              enableTooltips: true,
              onColorChanged: (Color value) {},
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
    return Padding(
      padding: edge16,
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              "编辑主题",
              style: textStyle20B,
            ),
          ),
          SmallCircleButton(
            onTap: () {
              themeEditModel.apply(themeItem == null, () {
                Navigator.pop(context);
              });
            },
            color: theme.scaffoldBackgroundColor,
            icon: Icons.save_rounded,
          ),
        ],
      ),
    );
  }
}
