import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('file', abbr: 'f', defaultsTo: 'windows_inno_setup.iss', help: 'ISS file path');

  final parse = parser.parse(arguments);
  final file = parse['file'];

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml not found');
    exit(1);
  }

  final pubspecYaml = loadYaml(pubspecFile.readAsStringSync());
  final versionStr = pubspecYaml['version'] as String;
  final version = versionStr.split('+').first;

  if (version.isEmpty) {
    print('Error: Version not found in pubspec.yaml');
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
