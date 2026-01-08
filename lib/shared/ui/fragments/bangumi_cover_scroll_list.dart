import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/home/providers/index_provider.dart';
import '../../../shared/internal/image_provider.dart';
import '../../../shared/internal/kit.dart';
import '../../models/bangumi_row.dart';
import 'sliver_bangumi_list.dart';

/// Provider for image width - will be overridden
final imageWidthProvider = Provider<int>((ref) {
  throw UnimplementedError('Must be overridden');
});

class BangumiCoverScrollListFragment extends ConsumerWidget {
  const BangumiCoverScrollListFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bangumiRows = ref.watch(indexProvider).value?.bangumiRows ?? [];
    return _buildList(context, ref, theme, bangumiRows);
  }

  Widget _buildList(BuildContext context, WidgetRef ref, ThemeData theme, List<BangumiRow> bangumiRows) {
    final bangumis = bangumiRows.map((e) => e.bangumis).expand((e) => e).sortedBy((e) => e.id);
    final length = bangumis.length;
    if (length == 0) {
      return const SizedBox();
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
        return ProviderScope(
          overrides: [
            currentBangumiProvider.overrideWithValue(bangumi),
            imageWidthProvider.overrideWithValue(imageWidth),
          ],
          child: const _BangumiCoverItem(),
        );
      },
    );
  }
}

/// Bangumi cover item - const, reads data from providers
class _BangumiCoverItem extends ConsumerWidget {
  const _BangumiCoverItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangumi = ref.watch(currentBangumiProvider);
    final imageWidth = ref.watch(imageWidthProvider);
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      child: Image(
        image: ResizeImage(CacheImage(bangumi.cover), width: imageWidth),
        fit: BoxFit.cover,
        isAntiAlias: true,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return const AspectRatio(aspectRatio: 1.0);
        },
      ),
    );
  }
}
