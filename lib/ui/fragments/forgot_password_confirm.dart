import 'package:flutter/material.dart';

import '../../topvars.dart';
import '../../widget/sliver_pinned_header.dart';

class ForgotPasswordConfirm extends StatelessWidget {
  const ForgotPasswordConfirm({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPinnedAppBar(title: '忘记密码'),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('如果您填入的邮箱已在本网站注册，则您会在几分钟内收到重置密码邮件，如果长时间等待后仍收不到邮件请确认'),
                  sizedBoxH12,
                  Text('1. 您是否已经注册'),
                  sizedBoxH4,
                  Text('2. 邮件是否输入正确'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
