import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mikan/features/bangumi/presentation/pages/record.dart';
import 'package:mikan/features/bangumi/presentation/pages/subgroup.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/widgets/bottom_sheet.dart';
import 'package:mikan/core/widgets/icon_button.dart';
import 'package:mikan/core/widgets/ripple_tap.dart';
import 'package:mikan/core/widgets/transition_container.dart';
import 'package:mikan/features/bangumi/presentation/widgets/select_subgroup.dart';
import 'package:mikan/core/components/simple_record_item.dart';

/// Record item widget - const, reads data from provider
@immutable
class ListRecordItem extends ConsumerWidget {
  const ListRecordItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final record = ref.watch(currentRecordProvider);
    final subgroups = record.groups;
    final subgroupsName = subgroups.map((e) => e.name).join('/');
    final closedColor = ElevationOverlay.applySurfaceTint(theme.cardColor, theme.colorScheme.surfaceTint, 1.0);
    return TransitionContainer(
      closedColor: closedColor,
      shape: const RoundedSuperellipseBorder(borderRadius: BorderRadius.all(Radius.circular(24.0))),
      routeSettings: const RouteSettings(name: '/record'),
      builder: (context, open) {
        return RippleTap(
          onTap: open,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Tooltip(
                        message: subgroupsName,
                        child: TransitionContainer(
                          closedColor: closedColor,
                          routeSettings: const RouteSettings(name: '/subgroup'),
                          builder: (context, open) {
                            return RippleTap(
                              borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                              onTap: () {
                                if (subgroups.length == 1) {
                                  final subgroup = subgroups[0];
                                  if (subgroup.id == null) {
                                    '无字幕组详情'.toast();
                                    return;
                                  }
                                  open();
                                } else {
                                  MBottomSheet.show(
                                    context,
                                    (context) => MBottomSheet(child: SelectSubgroup(subgroups: subgroups)),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: AlignmentDirectional.center,
                                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                      child: AutoSizeText(
                                        subgroups.map((e) => e.name.isNotEmpty ? e.name[0].toUpperCase() : '?').join(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onPrimaryContainer,
                                        ),
                                        minFontSize: 8.0,
                                      ),
                                    ),
                                    const Gap(8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            subgroupsName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleSmall,
                                          ),
                                          Text(
                                            record.publishAt,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          next: subgroups.isEmpty ? const SizedBox.shrink() : SubgroupPage(subgroup: subgroups.first),
                        ),
                      ),
                    ),
                    const Gap(8),
                    TMSMenuButton(torrent: record.torrent, magnet: record.magnet, share: record.share),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(record.title, style: theme.textTheme.bodySmall),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 20.0),
                child: Wrap(
                  runSpacing: 6.0,
                  spacing: 6.0,
                  children: [
                    if (record.size.isNotBlank)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                        ),
                        child: Text(
                          record.size,
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                        ),
                      ),
                    if (!record.tags.isNullOrEmpty)
                      ...List.generate(record.tags.length, (index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                          ),
                          child: Text(
                            record.tags[index],
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onTertiaryContainer),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      next: RecordPage(record: record),
    );
  }
}
