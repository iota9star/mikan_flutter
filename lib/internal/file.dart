import 'dart:io';

Future<Directory> getExistsDirectory(String path) async {
  final Directory directory = Directory(path);
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }
  return directory;
}

Future<String> getExistsDirectoryPath(
  Directory parent,
  String childPath,
) async {
  final Directory directory = await getExistsDirectory(
    parent.path + Platform.pathSeparator + childPath,
  );
  return directory.path;
}
