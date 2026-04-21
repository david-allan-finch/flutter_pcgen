//
// Copyright 2003 (C) David Hibbs <sage_sam@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.persistence.lst.LstFileLoader
import 'dart:io';
import 'package:flutter_pcgen/src/persistence/persistence_layer_exception.dart';

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
