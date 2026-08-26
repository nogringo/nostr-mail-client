import 'dart:io';

import 'package:path/path.dart' as p;

String resolvePath(String path, Directory repoRoot) {
  if (p.isAbsolute(path)) return path;
  final fromCurrent =
      FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  if (fromCurrent) return path;
  return p.join(repoRoot.path, path);
}

Directory findRepoRoot() {
  var current = Directory.current.absolute;
  while (true) {
    if (Directory(p.join(current.path, '.git')).existsSync()) {
      return current;
    }
    final parent = current.parent;
    if (parent.path == current.path) return Directory.current.absolute;
    current = parent;
  }
}
