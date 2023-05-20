import 'package:flutter/material.dart';

import '../../internal/consts.dart';
import '../../internal/hive.dart';
import '../../mikan_routes.dart';
import '../../topvars.dart';
import '../../widget/restart.dart';
import '../../widget/sliver_pinned_header.dart';

class SelectMirror extends StatelessWidget {
  const SelectMirror({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedMirrorUrl = MyHive.getMirrorUrl();
    final notifier = ValueNotifier(selectedMirrorUrl);
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                const SliverPinnedAppBar(title: '镜像地址'),
                ValueListenableBuilder(
                  valueListenable: notifier,
                  builder: (context, selected, child) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final url = MikanUrls.baseUrls[index];
                          return RadioListTile<String>(
                            title: Text(url),
                            value: url,
                            groupValue: selected,
                            onChanged: (value) {
                              notifier.value = value!;
                            },
                          );
                        },
                        childCount: MikanUrls.baseUrls.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.colorScheme.surfaceVariant),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('取消'),
                  ),
                ),
                sizedBoxW12,
                Expanded(
                  flex: 3,
                  child: ValueListenableBuilder(
                    valueListenable: notifier,
                    builder: (context, selected, child) {
                      return ElevatedButton(
                        onPressed: selectedMirrorUrl == selected
                            ? null
                            : () {
                                MikanUrls.baseUrl = selected;
                                MyHive.setMirrorUrl(selected);
                                Navigator.popUntil(
                                  context,
                                  (route) =>
                                      Routes.index.name == route.settings.name,
                                );
                                Restart.restartApp(context);
                              },
                        child: const Text('设置并重启'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
