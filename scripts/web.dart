import 'dart:io';

void main() {
  final file = File('build/web/index.html');
  if (file.existsSync()) {
    final newHtml = file.readAsStringSync().replaceAll(
          'flutter.js',
          'flutter.js?v=${DateTime.now().millisecondsSinceEpoch}',
        );
    file.writeAsStringSync(newHtml);
  }
}
