// Translation of pcgen.io.FileAccess

import 'dart:io';

/// Utility methods for file access in PCGen.
class FileAccess {
  FileAccess._();

  static String? readFile(String path) {
    try {
      return File(path).readAsStringSync();
    } catch (_) {
      return null;
    }
  }

  static bool writeFile(String path, String content) {
    try {
      File(path).writeAsStringSync(content);
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool fileExists(String path) => File(path).existsSync();
}
