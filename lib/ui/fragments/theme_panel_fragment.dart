import 'dart:math' as Math;

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/model/theme_item.dart';
import 'package:mikan_flutter/providers/view_models/theme_model.dart';
import 'package:mikan_flutter/ui/fragments/theme_edit_fragment.dart';
import 'package:mikan_flutter/widget/animated_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

@immutable
class ThemePanelFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThemeModel themeModel = Provider.of(context, listen: false);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: theme.backgroundColor,
      ),
      child: ValueListenableBuilder(
        valueListenable: Hive.box<ThemeItem>(HiveBoxKey.THEMES).listenable(),
        builder: (context, box, widget) {
          final int themeNum = box.length;
          return GridView.builder(
            padding: EdgeInsets.only(
              top: 8.0,
              left: 8.0,
              right: 8.0,
              bottom: 8.0,
            ),
            shrinkWrap: true,
            itemBuilder: (_, index) {
              if (index == themeNum) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    onPressed: () {
                      this._showEditThemePanel(context);
                    },
                    minWidth: 0,
                    shape: CircleBorder(),
                    color: theme.scaffoldBackgroundColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.all(0.0),
                    child: Icon(
                      FluentIcons.add_24_regular,
                      size: 16.0,
                    ),
                  ),
                );
              }
              final ThemeItem themeItem = box.getAt(index);
              final List<Color> outerColors = [
                Color(themeItem.primaryColor),
                Color(themeItem.accentColor),
                if (themeItem.lightScaffoldBackgroundColor != null)
                  Color(themeItem.lightScaffoldBackgroundColor),
                if (themeItem.darkScaffoldBackgroundColor != null)
                  Color(themeItem.darkScaffoldBackgroundColor),
                if (themeItem.lightBackgroundColor != null)
                  Color(themeItem.lightBackgroundColor),
                if (themeItem.darkBackgroundColor != null)
                  Color(themeItem.darkBackgroundColor),
              ];
              final List<Color> innerColors = themeItem.autoMode
                  ? [Colors.white, Colors.black]
                  : themeItem.isDark
                      ? [Colors.black]
                      : [Colors.white];
              return themeModel.themeItem.id == themeItem.id
                  ? AnimatedTapContainer(
                      onTap: () {
                        if (themeItem.id == 1) return "默认主题不可修改".toast();
                        this._showEditThemePanel(context, themeItem: themeItem);
                      },
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6.0,
                          ),
                        ],
                        border: Border.all(
                          color: theme.accentColor,
                          width: 2.0,
                        ),
                      ),
                      child: CustomPaint(
                        size: Size.square(36.0),
                        painter: ColorPiePainter(
                          outerColors: outerColors,
                          innerColors: innerColors,
                        ),
                      ),
                    )
                  : AnimatedTapContainer(
                      onTap: () {
                        themeModel.themeItem = themeItem;
                      },
                      onLongPress: () {
                        if (themeItem.id == 1) return "默认主题不可修改".toast();
                        this._showEditThemePanel(context, themeItem: themeItem);
                      },
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        size: Size.square(40.0),
                        painter: ColorPiePainter(
                          outerColors: outerColors,
                          innerColors: innerColors,
                        ),
                      ),
                    );
            },
            itemCount: themeNum + 1,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 56.0,
            ),
          );
        },
      ),
    );
  }

  _showEditThemePanel(
    final BuildContext context, {
    final ThemeItem themeItem,
  }) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      topRadius: Radius.circular(16.0),
      builder: (context) {
        return ThemeEditFragment(themeItem: themeItem);
      },
    );
  }
}

class ColorPiePainter extends CustomPainter {
  final List<Color> outerColors;

  final List<Color> innerColors;

  ColorPiePainter({
    this.outerColors,
    this.innerColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    assert(size.width == size.height);
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    final double outerSize = size.width;
    final Rect outerRect = Rect.fromLTWH(0, 0, outerSize, outerSize);
    final double outerSweepAngle = Math.pi * 2 / outerColors.length;
    for (int i = 0; i < outerColors.length; i++) {
      paint.color = outerColors[i];
      canvas.drawArc(
        outerRect,
        i * outerSweepAngle,
        outerSweepAngle,
        true,
        paint,
      );
    }
    final double innerSize = outerSize / 2;
    final double innerOffset = outerSize / 4;
    final Rect innerRect = Rect.fromLTWH(
      innerOffset,
      innerOffset,
      innerSize,
      innerSize,
    );
    final double innerSweepAngle = Math.pi * 2 / innerColors.length;
    for (int i = 0; i < innerColors.length; i++) {
      paint.color = innerColors[i];
      canvas.drawArc(
        innerRect,
        i * innerSweepAngle,
        innerSweepAngle,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
