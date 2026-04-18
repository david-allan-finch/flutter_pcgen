import 'dart:io';
import '../persistence_layer_exception.dart';

// Utility class for reading LST file content from disk.
class LstFileLoader {
  LstFileLoader._(); // utility class

  static const int lineCommentChar = 0x23; // '#'
  static const String lineSeparatorRegexp = r'(\r\n?|\n)';
  static const String _bom = '\uFEFF';

  /// Read the content of a file at [uri] (file path string) and return it.
  /// Returns null on error.
  static Future<String?> readFromURI(String? uri) async {
    if (uri == null) {
      throw PersistenceLayerException('readFromURI() received a null URI parameter!');
    }
    try {
      final parsed = Uri.parse(uri);
      if (parsed.scheme == 'file' || parsed.scheme == '') {
        String path = parsed.scheme == 'file' ? parsed.toFilePath() : uri;
        String content = await File(path).readAsString();
        if (content.startsWith(_bom)) {
          // Warn about BOM
          content = content.substring(1);
        }
        return content;
      }
      // Remote URIs not supported by default
      return null;
    } on IOException catch (e) {
      // Log but don't throw — a missing file shouldn't halt all loading
      stderr.writeln('ERROR reading $uri: $e');
      return null;
    }
  }

  /// Synchronous version for contexts where async is not available.
  static String? readFromURISync(String? uri) {
    if (uri == null) return null;
    try {
      final parsed = Uri.parse(uri);
      final path = parsed.scheme == 'file' ? parsed.toFilePath() : uri;
      String content = File(path).readAsStringSync();
      if (content.startsWith(_bom)) content = content.substring(1);
      return content;
    } catch (e) {
      stderr.writeln('ERROR reading $uri: $e');
      return null;
    }
  }
}
