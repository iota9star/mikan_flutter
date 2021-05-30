import 'dart:io';

import 'package:yaml/yaml.dart';

void main() {
  print('start write doc...');
  var before = DateTime.now().millisecondsSinceEpoch;
  var screenshots = getScreenshots();
  var libs = getLibs();
  writeDoc2README(screenshots, libs);
  print(
      'write doc end...${(DateTime.now().millisecondsSinceEpoch - before) / 1000.0}s');
}

void writeDoc2README(String screenshots, String libs) {
  var file = File("README.md");
  var lines = file.readAsLinesSync();
  var flag = false;
  lines.removeWhere((line) {
    if (line.startsWith("## Screenshot") ||
        line.startsWith("## Dependencies")) {
      flag = true;
    } else if (line.startsWith("## ")) {
      flag = false;
    }
    return flag;
  });
  var index = lines.indexWhere((ele) => ele.startsWith("## Thanks"));
  lines.insert(index, screenshots);
  lines.insert(index + 1, libs);
  file.writeAsStringSync(lines.join("\n"));
}

String getScreenshots() {
  var screenshotDir = Directory("static${Platform.pathSeparator}screenshot");
  var screenshots = screenshotDir.listSync();
  var sb = StringBuffer(
      "## Screenshot  \n\n| :heart: | :fire: | :sparkles: |  \n| -----| ---- | ---- |  \n");
  var length = screenshots.length;
  for (var i = 0; i < length; i++) {
    var file = screenshots.elementAt(i);
    sb.write("| ![](");
    sb.write(file.path.replaceAll(new RegExp(r'\\'), r'/'));
    sb.write(") ");
    if ((i + 1) % 3 == 0 || i == length - 1) {
      sb.write("|  \n");
    }
  }
  return sb.toString();
}

String getLibs() {
  var file = File("pubspec.yaml");
  var yaml = file.readAsStringSync();
  var doc = loadYaml(yaml) as YamlMap;
  var deps = doc["dependencies"].keys;
  var devDeps = doc["dev_dependencies"].keys;
  var sb = StringBuffer("## Dependencies  \n\n");
  for (var value in deps) {
    if (value == "flutter") {
      continue;
    }
    sb.write(
        "[![$value](https://img.shields.io/pub/v/$value?label=$value&logo=dart)](https://pub.dev/packages/$value) ");
  }
  sb.write(" \n---  \n");
  for (var value in devDeps) {
    if (value == "flutter") {
      continue;
    }
    sb.write(
        "[![$value](https://img.shields.io/pub/v/$value?label=$value&logo=dart)](https://pub.dev/packages/$value) ");
  }
  sb.write("\n");
  return sb.toString();
}
