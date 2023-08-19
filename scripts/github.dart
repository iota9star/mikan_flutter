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
  final parser = ArgParser()
    ..addOption('fun', abbr: 'f', allowed: Fun.values.map((e) => e.name))
    ..addOption('token', abbr: 't')
    ..addOption('artifacts', abbr: 'a');
  final parse = parser.parse(arguments);
  final token = parse['token'];
  final artifacts = parse['artifacts'];
  final shell = Shell();
  final result = await shell.run('git remote -v');
  final urlParts =
      result.first.stdout.toString().trim().split('\n').last.split('/');
  final repo = [
    urlParts[urlParts.length - 2],
    urlParts[urlParts.length - 1].split(' ').first.replaceAll('.git', ''),
  ].join('/');
  switch (Fun.values.firstWhere((e) => e.name == parse['fun'])) {
    case Fun.release:
      await _release(
        shell: shell,
        repo: repo,
        token: token,
        artifacts: artifacts,
      );
  }
}

Future<void> _release({
  required Shell shell,
  required String token,
  required String repo,
  required String artifacts,
}) async {
  await shell.run('git remote set-url origin https://$token@github.com/$repo');
  var result = await shell.run('git show -s');
  final commitId =
      RegExp(r'\s([a-z\d]{40})\s').firstMatch(result.first.stdout)?.group(1);
  if (commitId == null) {
    throw StateError("Can't get ref.");
  }
  result = await shell.run('git log --pretty=format:"%an;%ae" $commitId -1');
  final pair = result.first.stdout.toString().split(';');
  final ref = commitId.substring(0, 7);
  final root = Directory.current;
  final pubspec = File(join(root.path, 'pubspec.yaml'));
  final yaml = loadYaml(pubspec.readAsStringSync());
  final version = yaml['version'] as String;
  final verArr = version.split('+');
  final tag = 'v${verArr.first}_$ref';
  // result = await shell.run("git branch");
  // var branch = result.first.stdout
  //     .toString()
  //     .split("\n")
  //     .firstWhere((e) => e.startsWith("*"))
  //     .split(" ")
  //     .last;
  result = await shell.run('git ls-remote --tags');
  final tags = result.first.stdout.toString();
  final has =
      tags.split('\n').any((s) => s.split('refs/tags/').last.startsWith(tag));
  if (!has) {
    try {
      await shell.run('git'
          ' -c user.name=${pair[0]}'
          ' -c user.email=${pair[1]}'
          ' tag $tag');
      await shell.run('git push origin $tag');
    } catch (e) {
      print(e);
    }
  }
  dynamic id;
  try {
    final response = await http.get(
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
    final data = jsonEncode({
      'tag_name': tag,
      'target_commitish': 'main',
      'name': tag,
      'body': '',
      'draft': false,
      'prerelease': false,
      'generate_release_notes': true,
    });
    final response = await http.post(
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
  final files = Glob(artifacts, recursive: true).listSync(root: root.path);
  final response = await http.get(
    Uri.parse('https://api.github.com/repos/$repo/releases/$id/assets'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github.v3+json',
    },
  );
  final assets = jsonDecode(response.body) as List?;
  print('assets: ${assets?.map((e) => e['name'])}');
  for (final file in files) {
    if (file is File) {
      final filePath = file.absolute.path;
      final fileName = basename(filePath);
      print('prepare upload: $filePath');
      final exist = assets?.firstWhereOrNull((e) {
        return e['name'] == fileName;
      });
      if (exist != null) {
        print('exist asset: ${exist?['name']}');
        // delete exist assert
        final response = await http.delete(
          Uri.parse(
            'https://api.github.com/repos/$repo/releases/assets/${exist['id']}',
          ),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        );
        print('delete end: ${response.statusCode}');
      }
      // upload asset.
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://uploads.github.com/repos/$repo/releases/$id/assets?name=$fileName',
        ),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      });
      final response = await request.send();
      print('upload end: ${response.statusCode}, $filePath');
    }
  }
  print('task end');
  exit(0);
}
