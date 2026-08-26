import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final String output = Platform.environment['MIKAN_PIXA_PROFILE_OUTPUT'] ?? 'g43_current';
  await integrationDriver(
    responseDataCallback: (Map<String, dynamic>? data) {
      return writeResponseData(data, testOutputFilename: output, destinationDirectory: 'build');
    },
  );
}
