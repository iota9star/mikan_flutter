import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/hive.dart';
import 'package:mikan_flutter/model/theme_item.dart';
import 'package:mikan_flutter/providers/theme_model.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/ui/fragments/theme_edit_fragment.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

@immutable
class ThemePanelFragment extends StatelessWidget {
  const ThemePanelFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    return Container(
      margin: edgeH16,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
      ),
      padding: edge16,
      child: ValueListenableBuilder<Box<ThemeItem>>(
        valueListenable: Hive.box<ThemeItem>(HiveBoxKey.themes).listenable(),
        builder: (context, box, widget) {
          final values = box.values.toList(growable: false);
          Widget buildItem(ThemeItem themeItem) {
            final List<Color> outerColors = [
              Color(themeItem.primaryColor),
              Color(themeItem.accentColor),
            ];
            final selected = themeModel.themeItem.id == themeItem.id;
            final selectedColor = theme.textTheme.bodyText1!.color!;
            final circle = Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: outerColors,
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomCenter,
                  stops: const [0.0, 0.78],
                ),
                border: selected
                    ? Border.all(
                        color: selectedColor,
                        width: 2.0,
                      )
                    : null,
                shape: BoxShape.circle,
              ),
              child: selected
                  ? Icon(
                      Icons.done_rounded,
                      size: 20.0,
                      color: selectedColor,
                    )
                  : null,
            );
            return selected
                ? ScalableRippleTap(
                    shape: const CircleBorder(),
                    onTap: () {
                      if (themeItem.id == 1) {
                        "默认主题不可修改".toast();
                        return;
                      }
                      _showEditThemePanel(context, themeItem: themeItem);
                    },
                    child: circle,
                  )
                : ScalableRippleTap(
                    onTap: () {
                      themeModel.themeItem = themeItem;
                    },
                    onLongPress: () {
                      if (themeItem.id == 1) {
                        "默认主题不可修改".toast();
                        return;
                      }
                      _showEditThemePanel(context, themeItem: themeItem);
                    },
                    shape: const CircleBorder(),
                    child: circle,
                  );
          }

          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              for (ThemeItem theme in values) buildItem(theme),
              ScalableRippleTap(
                onTap: () {
                  _showEditThemePanel(context);
                },
                shape: const CircleBorder(),
                color: theme.scaffoldBackgroundColor,
                child: const SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: Icon(
                    Icons.add_rounded,
                    size: 16.0,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditThemePanel(
    final BuildContext context, {
    final ThemeItem? themeItem,
  }) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      topRadius: radius0,
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
    required this.outerColors,
    required this.innerColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    assert(size.width == size.height);
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    final double outerSize = size.width;
    final Rect outerRect = Rect.fromLTWH(0, 0, outerSize, outerSize);
    final double outerSweepAngle = math.pi * 2 / outerColors.length;
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
    final double innerSweepAngle = math.pi * 2 / innerColors.length;
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
