import 'package:flutter/material.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/mikan_flutter_routes.dart';
import 'package:mikan_flutter/model/record_item.dart';
import 'package:mikan_flutter/topvars.dart';
import 'package:mikan_flutter/widget/icon_button.dart';
import 'package:mikan_flutter/widget/ripple_tap.dart';

@immutable
class NormalRecordItem extends StatelessWidget {
  final int index;
  final RecordItem record;
  final VoidCallback onTap;
  final ThemeData theme;

  const NormalRecordItem({
    Key? key,
    required this.index,
    required this.record,
    required this.onTap,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subgroups = record.groups;
    final accentTagStyle = textStyle10WithColor(
      theme.secondary.isDark ? Colors.white : Colors.black,
    );
    final primaryTagStyle = textStyle10WithColor(
      theme.primary.isDark ? Colors.white : Colors.black,
    );
    return ScalableRippleTap(
      onTap: onTap,
      color: theme.colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              record.title,
              style: textStyle14B500,
            ),
            sizedBoxH8,
            Wrap(
              runSpacing: 4.0,
              spacing: 4.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (subgroups.isSafeNotEmpty)
                  for (final subgroup in subgroups)
                    Tooltip(
                      message: subgroup.name,
                      child: RippleTap(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.subgroup.name,
                            arguments: Routes.subgroup.d(
                              subgroup: subgroup,
                            ),
                          );
                        },
                        color: theme.primary,
                        shape: const CircleBorder(),
                        child: SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: Center(
                            child: Text(
                              subgroup.name[0],
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                color: theme.primary.isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                if (record.size.isNotBlank)
                  Container(
                    padding: edgeH4V2,
                    decoration: BoxDecoration(color: theme.secondary),
                    child: Text(
                      record.size,
                      style: accentTagStyle,
                    ),
                  ),
                if (!record.tags.isNullOrEmpty)
                  ...List.generate(record.tags.length, (index) {
                    return Container(
                      padding: edgeH4V2,
                      decoration: BoxDecoration(color: theme.primary),
                      child: Text(
                        record.tags[index],
                        style: primaryTagStyle,
                      ),
                    );
                  }),
              ],
            ),
            sizedBoxH8,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    record.publishAt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                sizedBoxW8,
                TorrentButton(payload: record.torrent),
                sizedBoxW8,
                MagnetButton(payload: record.magnet),
                sizedBoxW8,
                ShareButton(payload: record.shareString),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
