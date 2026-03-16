import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:mikan/app/routing/mikan_routes.dart';
import 'package:mikan/core/common/consts.dart';
import 'package:mikan/core/common/hive.dart';
import 'package:mikan/core/widgets/restart.dart';
import 'package:mikan/core/widgets/sliver_pinned_header.dart';

class SelectMirror extends StatefulWidget {
  const SelectMirror({super.key});

  @override
  State<SelectMirror> createState() => _SelectMirrorState();
}

class _SelectMirrorState extends State<SelectMirror> {
  late final ValueNotifier<String> _selectedMirrorNotifier;

  @override
  void initState() {
    super.initState();
    _selectedMirrorNotifier = ValueNotifier(MyHive.getMirrorUrl());
  }

  @override
  void dispose() {
    _selectedMirrorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMirrorUrl = MyHive.getMirrorUrl();
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                const SliverPinnedAppBar(title: '镜像地址'),
                ValueListenableBuilder(
                  valueListenable: _selectedMirrorNotifier,
                  builder: (context, selected, child) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final url = MikanUrls.baseUrls[index];
                        return RadioListTile<String>(
                          title: Text(url + (url.endsWith('.me') ? '' : ' (中国大陆)')),
                          value: url,
                          // ignore: deprecated_member_use
                          groupValue: selected,
                          // ignore: deprecated_member_use
                          onChanged: (value) {
                            _selectedMirrorNotifier.value = value!;
                          },
                        );
                      }, childCount: MikanUrls.baseUrls.length),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.colorScheme.surfaceContainerHighest)),
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
                const Gap(12),
                Expanded(
                  flex: 3,
                  child: ValueListenableBuilder(
                    valueListenable: _selectedMirrorNotifier,
                    builder: (context, selected, child) {
                      return ElevatedButton(
                        onPressed: selectedMirrorUrl == selected
                            ? null
                            : () async {
                                MikanUrls.baseUrl = selected;
                                await MyHive.setMirrorUrl(selected);
                                if (!context.mounted) {
                                  return;
                                }
                                Navigator.popUntil(context, (route) => Routes.index.name == route.settings.name);
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
