import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../internal/extension.dart';
import '../../model/record_item.dart';
import '../../topvars.dart';
import '../../widget/icon_button.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/scalable_tap.dart';
import '../fragments/subgroup_bangumis.dart';

@immutable
class ListRecordItem extends StatelessWidget {
  const ListRecordItem({
    super.key,
    required this.index,
    required this.record,
    required this.onTap,
  });

  final int index;
  final RecordItem record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subgroups = record.groups;
    final subgroupsName = subgroups.map((e) => e.name).join('/');
    return ScalableCard(
      onTap: onTap,
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
                    child: RippleTap(
                      borderRadius: borderRadiusCircle,
                      onTap: () {
                        showSelectSubgroupPanel(context, subgroups);
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              child: AutoSizeText(
                                subgroups
                                    .map((e) => e.name[0].toUpperCase())
                                    .join(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                minFontSize: 8.0,
                              ),
                            ),
                            sizedBoxW8,
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
                      borderRadius: borderRadius8,
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
                        borderRadius: borderRadius8,
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
  }
}
