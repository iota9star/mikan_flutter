import 'dart:io';

Future<Directory> getExistsDirectory(String path) async {
  final Directory directory = Directory(path);
  if (!(await directory.exists())) {
    await directory.create(recursive: true);
  }
  return directory;
}

Future getExistsDirectoryPath(Directory parent, String childPath) async {
  final Directory directory = await getExistsDirectory(
      parent.path + Platform.pathSeparator + childPath);
  return directory.path;
}
