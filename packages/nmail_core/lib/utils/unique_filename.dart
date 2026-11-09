import 'package:path/path.dart' as p;

String uniqueFilename(String filename, bool Function(String name) isTaken) {
  if (!isTaken(filename)) return filename;
  final base = p.basenameWithoutExtension(filename);
  final extension = p.extension(filename);
  var index = 1;
  while (isTaken('$base ($index)$extension')) {
    index++;
  }
  return '$base ($index)$extension';
}
