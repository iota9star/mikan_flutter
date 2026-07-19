import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:mikan/res/assets.gen.dart';
import 'package:mikan/core/common/extension.dart';
import 'package:mikan/core/models/announcement.dart';
import 'package:mikan/core/widgets/placeholder_text.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';
import 'package:mikan/core/common/app_layout.dart';
import 'package:mikan/features/home/application/index_provider.dart';

@FFRoute(name: '/announcements')
class Announcements extends ConsumerWidget {
  const Announcements({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final announcementsAsync = ref.watch(indexProvider);
    return Scaffold(
      body: EasyRefresh(
        onRefresh: () => ref.read(indexProvider.notifier).refresh(),
        header: defaultHeader,
        child: announcementsAsync.when(
          data: (indexData) {
            final v = indexData.announcements;
            return CustomScrollView(
              slivers: [
                const SliverPinnedAppBar(title: '公告'),
                if (v.isNullOrEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Center(
                        child: Column(
                          children: [
                            Assets.mikan.image(width: 64.0),
                            const Gap(12),
                            Text('暂无数据', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index.isOdd) {
                        return const Divider(indent: 24.0, endIndent: 24.0, height: 1.0, thickness: 1.0);
                      }
                      return _AnnouncementItem(announcement: v[index ~/ 2]);
                    }, childCount: v!.length + v.length - 1),
                  ),
                sliverGapH24WithNavBarHeight(context),
              ],
            );
          },
          loading: () => const CustomScrollView(
            slivers: [
              SliverPinnedAppBar(title: '公告'),
              SliverFillRemaining(child: Center(child: defaultLoadingWidget)),
            ],
          ),
          error: (error, stack) => CustomScrollView(
            slivers: [
              const SliverPinnedAppBar(title: '公告'),
              SliverFillRemaining(child: Center(child: Text('加载失败: $error'))),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders a single announcement. Owns the [TapGestureRecognizer]s for its URL
/// nodes so they are reused across rebuilds and disposed with the widget,
/// instead of being leaked on every build (the previous implementation created
/// a new recognizer per rebuild inside the `onMatched` builder).
class _AnnouncementItem extends StatefulWidget {
  const _AnnouncementItem({required this.announcement});

  final Announcement announcement;

  @override
  State<_AnnouncementItem> createState() => _AnnouncementItemState();
}

class _AnnouncementItemState extends State<_AnnouncementItem> {
  /// Lazily-built recognizers keyed by node index. Reused across rebuilds.
  final Map<int, TapGestureRecognizer> _recognizers = {};

  TapGestureRecognizer _recognizerFor(AnnouncementNode node, int nodeIndex) {
    return _recognizers.putIfAbsent(nodeIndex, () {
      final r = TapGestureRecognizer();
      r.onTap = () {
        final place = node.place;
        if (place != null && place.trim().isNotEmpty) {
          launchUrlString(place);
        }
      };
      return r;
    });
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = widget.announcement;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: PlaceholderText(
        a.text,
        onMatched: (pos, matched) {
          if (pos == 0) {
            return TextSpan(
              text: matched.group(1),
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700),
            );
          }
          int p = 0;
          for (int i = 0; i < a.nodes.length; ++i) {
            final n = a.nodes[i];
            if (n.type != null) {
              p++;
              if (p == pos) {
                if (n.type == 'url') {
                  return TextSpan(
                    text: matched.group(1),
                    style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w400),
                    recognizer: _recognizerFor(n, i),
                  );
                }
                if (n.type == 'bold') {
                  return TextSpan(
                    text: matched.group(1),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  );
                }
              }
            }
          }
          return TextSpan(text: matched.group(1));
        },
      ),
    );
  }
}
