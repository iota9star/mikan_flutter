import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:yaml/yaml.dart';

enum Fun {
  release,
}

Future<void> main(List<String> arguments) async {
  var parser = ArgParser()
    ..addOption('fun', abbr: 'f', allowed: Fun.values.map((e) => e.name))
    ..addOption('token', abbr: 't')
    ..addOption('artifacts', abbr: 'a');
  var parse = parser.parse(arguments);
  var token = parse['token'];
  var artifacts = parse['artifacts'];
  var shell = Shell();
  var result = await shell.run("git remote -v");
  var urlParts =
  result.first.stdout.toString().trim().split("\n").last.split("/");
  var repo = [
    urlParts[urlParts.length - 2],
    urlParts[urlParts.length - 1].split(" ").first.replaceAll(".git", '')
  ].join("/");
  switch (Fun.values.firstWhere((e) => e.name == parse['fun'])) {
    case Fun.release:
      await _release(
        shell: shell,
        repo: repo,
        token: token,
        artifacts: artifacts,
      );
      break;
  }
}

Future<void> _release({
  required Shell shell,
  required String token,
  required String repo,
  required String artifacts,
}) async {
  await shell.run("git remote set-url origin https://$token@github.com/$repo");
  var result = await shell.run("git show -s");
  var commitId =
  RegExp(r"\s([a-z\d]{40})\s").firstMatch(result.first.stdout)?.group(1);
  if (commitId == null) {
    throw StateError("Can't get ref.");
  }
  result = await shell.run('git log --pretty=format:"%an;%ae" $commitId -1');
  var pair = result.first.stdout.toString().split(";");
  var ref = commitId.substring(0, 7);
  var root = Directory.current;
  var pubspec = File(join(root.path, 'pubspec.yaml'));
  var yaml = loadYaml(pubspec.readAsStringSync());
  var version = yaml['version'] as String;
  var verArr = version.split('+');
  var tag = "v${verArr.first}_$ref";
  // result = await shell.run("git branch");
  // var branch = result.first.stdout
  //     .toString()
  //     .split("\n")
  //     .firstWhere((e) => e.startsWith("*"))
  //     .split(" ")
  //     .last;
  result = await shell.run("git ls-remote --tags");
  var tags = result.first.stdout.toString();
  var has =
  tags.split("\n").any((s) => s.split("refs/tags/").last.startsWith(tag));
  if (!has) {
    try {
      await shell.run("git"
          " -c user.name=${pair[0]}"
          " -c user.email=${pair[1]}"
          " tag $tag");
      await shell.run("git push origin $tag");
    } catch (e) {
      print(e);
    }
  }
  dynamic id;
  try {
    var response = await http.get(
      Uri.parse('https://api.github.com/repos/$repo/releases/tags/$tag'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    id = jsonDecode(response.body)?['id'];
  } catch (e) {
    print(e);
  }
  if (id == null) {
    var data = jsonEncode({
      "tag_name": tag,
      "target_commitish": "main",
      "name": tag,
      "body": "",
      "draft": false,
      "prerelease": false,
      "generate_release_notes": true
    });
    var response = await http.post(
      Uri.parse('https://api.github.com/repos/$repo/releases'),
      body: data,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    id = jsonDecode(response.body)?['id'];
  }
  print('release id: $id');
  if (id == null) {
    throw StateError(result.first.stdout);
  }
  var files = Glob(artifacts, recursive: true).listSync(root: root.path);
  var response = await http.get(
    Uri.parse('https://api.github.com/repos/$repo/releases/$id/assets'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github.v3+json',
    },
  );
  var assets = jsonDecode(response.body) as List?;
  print('assets: ${assets?.map((e) => e['name'])}');
  for (var file in files) {
    if (file is File) {
      var filePath = file.absolute.path;
      var fileName = basename(filePath);
      print('prepare upload: $filePath');
      var exist = assets?.firstWhereOrNull((e) {
        return e['name'] == fileName;
      });
      if (exist != null) {
        print('exist asset: ${exist?['name']}');
        // delete exist assert
        var response = await http.delete(
          Uri.parse(
              'https://api.github.com/repos/$repo/releases/assets/${exist['id']}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        );
        print('delete end: ${response.statusCode}');
      }
      // upload asset.
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://uploads.github.com/repos/$repo/releases/$id/assets?name=$fileName'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      });
      var response = await request.send();
      print('upload end: ${response.statusCode}, $filePath');
    }
  }
  print('task end');
  exit(0);
}
