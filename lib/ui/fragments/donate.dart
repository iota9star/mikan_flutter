import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../topvars.dart';
import '../../widget/ripple_tap.dart';
import '../../widget/sliver_pinned_header.dart';

class Donate extends StatelessWidget {
  const Donate({super.key});

  static const _list = [
    ['支付宝', '按照提示，点击打开支付宝即可', 'https://donate.bytex.space?p=alipay'],
    ['微信', '微信扫码或者下载图片在微信内识别', 'https://donate.bytex.space/'],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverPinnedAppBar(title: '支持一下'),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _list[index];
                final title = Text(
                  item[0],
                  style: theme.textTheme.bodyLarge,
                );
                return RippleTap(
                  child: Padding(
                    padding: edgeH24V12,
                    child: Row(
                      children: [
                        CircleAvatar(
                          child: Text(item[0][0]),
                        ),
                        sizedBoxW16,
                        if (item[1].isEmpty)
                          title
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title,
                              Text(
                                item[1],
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  onTap: () {
                    launchUrlString(
                      item[2],
                      mode: LaunchMode.externalNonBrowserApplication,
                    );
                  },
                );
              },
              childCount: _list.length,
            ),
          ),
        ],
      ),
    );
  }
}
