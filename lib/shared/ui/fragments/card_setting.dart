import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../shared/internal/hive.dart';
import '../../../topvars.dart';
import '../../widgets/sliver_pinned_header.dart';

/// Unified card setting fragment supporting different setting types
enum CardSettingType {
  ratio(title: '卡片比例'),
  width(title: '卡片宽度'),
  style(title: '卡片样式');

  const CardSettingType({required this.title});

  final String title;
}

/// Unified card setting widget
class CardSettingFragment extends StatelessWidget {
  const CardSettingFragment({super.key, required this.type});

  final CardSettingType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPinnedAppBar(title: type.title, maxExtent: 120.0),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ValueListenableBuilder(
                valueListenable: MyHive.settings.listenable(
                  keys: type == CardSettingType.ratio
                      ? [SettingsHiveKey.cardRatio]
                      : type == CardSettingType.width
                      ? [SettingsHiveKey.cardWidth]
                      : [SettingsHiveKey.cardStyle],
                ),
                builder: (context, _, child) {
                  return type == CardSettingType.style ? _buildStyleSelector(context) : _buildSlider(context);
                },
              ),
            ),
          ),
          sliverGapH24WithNavBarHeight(context),
        ],
      ),
    );
  }

  Widget _buildSlider(BuildContext context) {
    final value = type == CardSettingType.ratio ? MyHive.getCardRatio().toDouble() : MyHive.getCardWidth().toDouble();

    final min = type == CardSettingType.ratio ? 0.4 : 100.0;
    final max = type == CardSettingType.ratio ? 1.2 : 400.0;
    final divisions = type == CardSettingType.ratio ? 40 : 15;

    return Slider(
      value: value,
      onChanged: (v) {
        final decimalValue = Decimal.parse(v.toString());
        if (type == CardSettingType.ratio) {
          MyHive.setCardRatio(decimalValue);
        } else {
          MyHive.setCardWidth(decimalValue);
        }
      },
      min: min,
      max: max,
      divisions: divisions,
      label: type == CardSettingType.ratio ? value.toStringAsFixed(2) : value.toStringAsFixed(0),
    );
  }

  Widget _buildStyleSelector(BuildContext context) {
    final value = MyHive.getCardStyle();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SegmentedButton<int>(
        showSelectedIcon: false,
        segments: List.generate(4, (index) {
          final v = index + 1;
          return ButtonSegment(value: v, label: Text('样式$v'));
        }),
        onSelectionChanged: (v) {
          MyHive.setCardStyle(v.first);
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.resolveWith((states) {
            return const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0)));
          }),
        ),
        selected: {value},
      ),
    );
  }
}

/// Backward compatibility aliases
class CardRatio extends StatelessWidget {
  const CardRatio({super.key});

  @override
  Widget build(BuildContext context) => const CardSettingFragment(type: CardSettingType.ratio);
}

class CardWidth extends StatelessWidget {
  const CardWidth({super.key});

  @override
  Widget build(BuildContext context) => const CardSettingFragment(type: CardSettingType.width);
}

class CardStyle extends StatelessWidget {
  const CardStyle({super.key});

  @override
  Widget build(BuildContext context) => const CardSettingFragment(type: CardSettingType.style);
}
