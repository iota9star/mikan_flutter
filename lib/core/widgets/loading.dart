import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, required this.msg});

  final String msg;

  @override
  Widget build(BuildContext context) {
    return const Center(child: ExpressiveLoadingIndicator(constraints: BoxConstraints.tightFor(width: 36, height: 36)));
  }
}
