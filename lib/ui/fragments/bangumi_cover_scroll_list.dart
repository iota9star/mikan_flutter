import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/image_provider.dart';
import '../../internal/kit.dart';
import '../../model/bangumi_row.dart';
import '../../providers/index_model.dart';
import '../../topvars.dart';
import 'sliver_bangumi_list.dart';

class BangumiCoverScrollListFragment extends StatefulWidget {
  const BangumiCoverScrollListFragment({super.key});

  @override
  State<StatefulWidget> createState() => _BangumiCoverScrollListFragmentState();
}

class _BangumiCoverScrollListFragmentState
    extends State<BangumiCoverScrollListFragment> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Selector<IndexModel, List<BangumiRow>>(
      selector: (_, model) => model.bangumiRows,
      shouldRebuild: (pre, next) => pre.length != next.length,
      builder: (_, bangumiRows, __) {
        return _buildList(theme, bangumiRows);
      },
    );
  }

  Widget _buildList(ThemeData theme, List<BangumiRow> bangumiRows) {
    final bangumis = bangumiRows
        .map((e) => e.bangumis)
        .expand((e) => e)
        .sortedBy((e) => e.id);
    final length = bangumis.length;
    if (length == 0) {
      return sizedBox;
    }
    const maxCrossAxisExtent = 120.0;
    const spacing = 8.0;
    final size = calcGridItemSizeWithMaxCrossAxisExtent(
      crossAxisExtent: context.screenWidth - spacing * 2,
      maxCrossAxisExtent: maxCrossAxisExtent,
      crossAxisSpacing: spacing,
      childAspectRatio: 1.0,
    );
    final imageWidth = (size.width * context.devicePixelRatio).ceil();
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      padding: const EdgeInsets.all(spacing),
      itemBuilder: (_, index) {
        final bangumi = bangumis[index % length];
        return ClipRRect(
          borderRadius: borderRadius4,
          child: Image(
            image: ResizeImage(
              CacheImage(bangumi.cover),
              width: imageWidth,
            ),
            fit: BoxFit.cover,
            isAntiAlias: true,
            loadingBuilder: (
              context,
              child,
              loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }
              return const AspectRatio(aspectRatio: 1.0);
            },
          ),
        );
      },
    );
  }
}
