import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('version', abbr: 'v', help: 'Version to set (e.g., 1.3.1)')
    ..addOption('file', abbr: 'f', defaultsTo: 'windows_inno_setup.iss', help: 'ISS file path');

  final parse = parser.parse(arguments);
  final version = parse['version'];
  final file = parse['file'];

  if (version == null || version.isEmpty) {
    print('Error: Version is required');
    print(parser.usage);
    exit(1);
  }

  final issFile = File(file);
  if (!issFile.existsSync()) {
    print('Error: File not found: $file');
    exit(1);
  }

  final bytes = issFile.readAsBytesSync();
  final content = utf8.decode(bytes);
  final pattern = RegExp(r'#define MyAppVersion ".*"');

  if (!content.contains(pattern)) {
    print('Error: Cannot find MyAppVersion definition in $file');
    exit(1);
  }

  final newContent = content.replaceFirst(pattern, '#define MyAppVersion "$version"');
  final bom = bytes.take(3).toList();
  final newBytes = [...bom, ...utf8.encode(newContent)];
  issFile.writeAsBytesSync(newBytes);

  print('Updated MyAppVersion to: $version');
}
