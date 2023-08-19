import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, required this.msg});

  final String msg;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 36.0,
        height: 36.0,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
