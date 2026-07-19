import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';

import 'package:mikan/core/common/extension.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, required this.msg});

  final String msg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ExpressiveLoadingIndicator(constraints: BoxConstraints.tightFor(width: 36, height: 36)),
          if (msg.isNotBlank) ...[const SizedBox(height: 12), Text(msg, style: theme.textTheme.bodySmall)],
        ],
      ),
    );
  }
}
