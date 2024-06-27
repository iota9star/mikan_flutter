import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../internal/extension.dart';
import '../../model/record_item.dart';
import '../../topvars.dart';
import '../../widget/bottom_sheet.dart';
import '../../widget/icon_button.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/transition_container.dart';
import '../fragments/select_subgroup.dart';
import '../pages/record.dart';
import '../pages/subgroup.dart';

@immutable
class ListRecordItem extends StatelessWidget {
  const ListRecordItem({
    super.key,
    required this.index,
    required this.record,
  });

  final int index;
  final RecordItem record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subgroups = record.groups;
    final subgroupsName = subgroups.map((e) => e.name).join('/');
    final closedColor = ElevationOverlay.applySurfaceTint(
      theme.cardColor,
      theme.colorScheme.surfaceTint,
      1.0,
    );
    return TransitionContainer(
      closedColor: closedColor,
      builder: (context, open) {
        return RippleTap(
          onTap: open,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                  top: 8.0,
                  bottom: 4.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Tooltip(
                        message: subgroupsName,
                        child: TransitionContainer(
                          closedColor: closedColor,
                          builder: (context, open) {
                            return RippleTap(
                              borderRadius: borderRadius6,
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
                                    (context) => MBottomSheet(
                                      child: SelectSubgroup(
                                        subgroups: subgroups,
                                      ),
                                    ),
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
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: AlignmentDirectional.center,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0,
                                      ),
                                      child: AutoSizeText(
                                        subgroups
                                            .map(
                                              (e) => e.name[0].toUpperCase(),
                                            )
                                            .join(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: theme
                                              .colorScheme.onPrimaryContainer,
                                        ),
                                        minFontSize: 8.0,
                                      ),
                                    ),
                                    sizedBoxW8,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                          next: SubgroupPage(subgroup: subgroups.first),
                        ),
                      ),
                    ),
                    sizedBoxW8,
                    TMSMenuButton(
                      torrent: record.torrent,
                      magnet: record.magnet,
                      share: record.share,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: edgeH16,
                child: Text(
                  record.title,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 8.0,
                  bottom: 20.0,
                ),
                child: Wrap(
                  runSpacing: 6.0,
                  spacing: 6.0,
                  children: [
                    if (record.size.isNotBlank)
                      Container(
                        padding: edgeH6V4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: borderRadius6,
                        ),
                        child: Text(
                          record.size,
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    if (!record.tags.isNullOrEmpty)
                      ...List.generate(record.tags.length, (index) {
                        return Container(
                          padding: edgeH6V4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: borderRadius6,
                          ),
                          child: Text(
                            record.tags[index],
                            style: theme.textTheme.labelSmall!.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
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
