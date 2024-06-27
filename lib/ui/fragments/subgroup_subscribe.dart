import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../internal/extension.dart';
import '../../internal/method.dart';
import '../../internal/repo.dart';
import '../../providers/bangumi_model.dart';
import '../../topvars.dart';
import '../../widget/sliver_pinned_header.dart';

class SubgroupSubscribe extends StatelessWidget {
  const SubgroupSubscribe(this.model, {super.key});

  final BangumiModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider.value(
      value: model,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverPinnedAppBar(
              title: '字幕组订阅',
              actions: [
                IconButton(
                  onPressed: () => wrapLoading(model.changeSubscribe),
                  icon: Selector<BangumiModel, bool>(
                    selector: (_, model) =>
                        model.bangumiDetail?.subscribed ?? false,
                    shouldRebuild: (pre, next) => pre != next,
                    builder: (_, subscribed, __) {
                      return Icon(
                        subscribed
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: subscribed ? theme.colorScheme.secondary : null,
                      );
                    },
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  '注：\n仅会显示订阅/RSS时适用，番组详情列表仍为全部条目。\n如果选择语言时最终未选中选择的值，说明当前字幕组不支持订阅选择的语言。',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            Consumer<BangumiModel>(
              builder: (context, model, child) {
                final subgroups = model.bangumiDetail!.subgroupBangumis.values
                    .toList(growable: false);
                return SliverList.builder(
                  itemBuilder: (context, index) {
                    final sub = subgroups[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 10.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  sub.name,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              if (!sub.rss.isNullOrBlank)
                                ElevatedButton(
                                  onPressed: () {
                                    sub.rss.copy();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(32.0, 32.0),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: borderRadius6,
                                    ),
                                  ),
                                  child: sub.subscribed
                                      ? Row(
                                          children: [
                                            const Icon(Icons.rss_feed_rounded),
                                            sizedBoxW4,
                                            Text(sub.sublang!),
                                          ],
                                        )
                                      : const Icon(Icons.rss_feed_rounded),
                                ),
                            ],
                          ),
                          sizedBoxH4,
                          SegmentedButton<int>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(value: 0, label: Text('全部')),
                              ButtonSegment(value: 1, label: Text('简中')),
                              ButtonSegment(value: 2, label: Text('繁中')),
                              ButtonSegment(value: -1, label: Text('退订')),
                            ],
                            selected: {sub.state},
                            style: ButtonStyle(
                              shape:
                                  WidgetStateProperty.resolveWith((states) {
                                return const RoundedRectangleBorder(
                                  borderRadius: borderRadius12,
                                );
                              }),
                            ),
                            onSelectionChanged: (v) {
                              wrapLoading(() async {
                                final x = v.first;
                                if (x == -1) {
                                  await Repo.subscribeBangumi(
                                    int.parse(model.id),
                                    true,
                                    subgroupId: int.tryParse(sub.dataId),
                                  );
                                } else {
                                  await Repo.subscribeBangumi(
                                    int.parse(model.id),
                                    false,
                                    subgroupId: int.tryParse(sub.dataId),
                                    language: x == 0 ? null : x,
                                  );
                                }
                                await model.load();
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: subgroups.length,
                );
              },
            ),
            sliverSizedBoxH24WithNavBarHeight(context),
          ],
        ),
      ),
    );
  }
}
