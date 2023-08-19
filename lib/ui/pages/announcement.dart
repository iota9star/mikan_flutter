import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../internal/extension.dart';
import '../../model/announcement.dart';
import '../../providers/index_model.dart';
import '../../res/assets.gen.dart';
import '../../topvars.dart';
import '../../widget/placeholder_text.dart';
import '../../widget/sliver_pinned_header.dart';

@FFRoute(name: '/announcements')
class Announcements extends StatelessWidget {
  const Announcements({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = Provider.of<IndexModel>(context, listen: false);
    return Scaffold(
      body: EasyRefresh(
        onRefresh: model.refresh,
        header: defaultHeader,
        refreshOnStart: true,
        child: CustomScrollView(
          slivers: [
            const SliverPinnedAppBar(title: '公告'),
            Selector<IndexModel, List<Announcement>?>(
              builder: (context, v, child) {
                if (v.isNullOrEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Center(
                        child: Column(
                          children: [
                            Assets.mikan.image(width: 64.0),
                            sizedBoxH12,
                            Text(
                              '暂无数据',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: v!.length + v.length - 1,
                    (context, index) {
                      if (index.isOdd) {
                        return const Divider(
                          indent: 24.0,
                          endIndent: 24.0,
                          height: 1.0,
                          thickness: 1.0,
                        );
                      }
                      final a = v[index ~/ 2];
                      return Container(
                        margin: edgeH24,
                        padding: edgeV16,
                        child: PlaceholderText(
                          a.text,
                          onMatched: (pos, matched) {
                            if (pos == 0) {
                              return TextSpan(
                                text: matched.group(1),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
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
                                      style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          if (!n.place.isNullOrBlank) {
                                            launchUrlString(n.place!);
                                          }
                                        },
                                    );
                                  }
                                  if (n.type == 'bold') {
                                    return TextSpan(
                                      text: matched.group(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                            return TextSpan(text: matched.group(1));
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              selector: (_, model) => model.announcements,
            ),
            sliverSizedBoxH24WithNavBarHeight(context),
          ],
        ),
      ),
    );
  }
}
