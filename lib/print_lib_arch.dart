import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print("lib klasörü bulunamadı.");
    return;
  }

  print("📂 lib klasör yapısı:");
  _printDirectory(libDir, "");
}

void _printDirectory(Directory dir, String indent) {
  final entities = dir.listSync()..sort((a, b) => a.path.compareTo(b.path));

  for (var entity in entities) {
    if (entity is Directory) {
      print("$indent📂 ${_basename(entity.path)}");
      _printDirectory(entity, "$indent   ");
    } else if (entity is File) {
      print("$indent📄 ${_basename(entity.path)}");
    }
  }
}

String _basename(String path) {
  return path.split(Platform.pathSeparator).last;
}
