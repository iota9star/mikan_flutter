import 'dart:convert';
import 'dart:io';

import 'package:jiffy/jiffy.dart';

Future<void> main() async {
  final metaFile = File('releases/meta.json');
  final httpClient = HttpClient();
  final request = await httpClient.getUrl(
    Uri.parse(
      'https://api.github.com/repos/iota9star/mikan_flutter/releases/latest',
    ),
  );
  final response = await request.close();
  if (response.statusCode == HttpStatus.ok) {
    final join = await response.transform(const Utf8Decoder()).join();
    final result = jsonDecode(join);
    final arches = <String?>{
      'arm64-v8a',
      'armeabi-v7a',
      'x86_64',
      'universal',
      'win32',
    };
    final files = [
      ...result['assets'].map((it) {
        final name = it['name'];
        final arch = arches.firstWhere(
          name.contains,
          orElse: () => null,
        );
        final size = it['size'];
        final sizefmt = (size / 1024 / 1024).toStringAsFixed(2) + 'MB';
        return {
          'name': name,
          'arch': arch,
          'size': size,
          'sizefmt': sizefmt,
          'dl': it['browser_download_url'],
          'cdl':
              'https://cdn.jsdelivr.net/gh/iota9star/mikan_flutter@master/releases/$name',
        };
      }),
    ];
    await Jiffy.setLocale('zh_cn');
    final jiffy = Jiffy.parse(result['published_at'])..add(hours: 8);
    final meta = {
      'tag': result['tag_name'],
      'url': result['html_url'],
      'publishedAt': jiffy.yMMMMEEEEdjm,
      'zip': result['zipball_url'],
      'files': files,
    };
    await metaFile.writeAsString(jsonEncode(meta));
  }
}
