// Character file save/load.
//
// Writes in PCGen PCG v2 format (compatible with the Java PCGen application).
// Reads both PCG v2 and our older JSON format for backwards compatibility.

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';
import 'package:flutter_pcgen/src/io/pcg_character_io.dart';

class CharacterFileIO {
  static Future<Directory> _getCharDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'PCGen', 'characters'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Public alias used by the export dialog to produce a JSON preview.
  static Map<String, dynamic> sanitiseForJson(Map<String, dynamic> data) =>
      _sanitise(data);

  /// Produce a JSON-safe copy of [data] by dropping any values that are not
  /// a primitive, List, or Map. This guards against accidentally serialising
  /// CDOMObject instances that leaked into the data map.
  static Map<String, dynamic> _sanitise(Map<String, dynamic> data) {
    final out = <String, dynamic>{};
    for (final entry in data.entries) {
      final v = entry.value;
      if (v == null || v is bool || v is num || v is String) {
        out[entry.key] = v;
      } else if (v is List) {
        out[entry.key] = _sanitiseList(v);
      } else if (v is Map) {
        out[entry.key] = _sanitise(v.cast<String, dynamic>());
      }
      // Non-serialisable objects (CDOMObject instances) are silently dropped.
    }
    return out;
  }

  static List<dynamic> _sanitiseList(List<dynamic> list) => list.map((e) {
        if (e == null || e is bool || e is num || e is String) return e;
        if (e is List) return _sanitiseList(e);
        if (e is Map) return _sanitise(e.cast<String, dynamic>());
        return null; // drop non-serialisable items
      }).where((e) => e != null).toList();

  /// Save [character] to disk in PCG v2 format.
  /// Filename derives from the character name. Returns the path, or null on error.
  static Future<String?> save(CharacterFacadeImpl character) async {
    try {
      final dir = await _getCharDir();
      final name =
          character.getName().trim().isEmpty ? 'unnamed' : character.getName().trim();
      final safeName = name.replaceAll(RegExp(r'[^\w\s\-]'), '_');
      final file = File(p.join(dir.path, '$safeName.pcg'));
      await file.writeAsString(PCGCharacterIO.write(character), flush: true);
      character.setFilePath(file.path);
      return file.path;
    } catch (e) {
      print('CharacterFileIO.save error: $e');
      return null;
    }
  }

  /// Save [character] to an explicit [path] in PCG v2 format.
  static Future<bool> saveAs(CharacterFacadeImpl character, String path) async {
    try {
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsString(PCGCharacterIO.write(character), flush: true);
      character.setFilePath(path);
      return true;
    } catch (e) {
      print('CharacterFileIO.saveAs error: $e');
      return false;
    }
  }

  /// Save [character] as JSON (.json) — useful for debugging or backup.
  /// Returns the path written, or null on error.
  static Future<String?> saveJson(CharacterFacadeImpl character) async {
    try {
      final dir = await _getCharDir();
      final name =
          character.getName().trim().isEmpty ? 'unnamed' : character.getName().trim();
      final safeName = name.replaceAll(RegExp(r'[^\w\s\-]'), '_');
      final file = File(p.join(dir.path, '$safeName.json'));
      final json = const JsonEncoder.withIndent('  ').convert(_sanitise(character.toJson()));
      await file.writeAsString(json, flush: true);
      return file.path;
    } catch (e) {
      print('CharacterFileIO.saveJson error: $e');
      return null;
    }
  }

  /// Load a character from [path].
  /// Supports both PCG v2 format (Java PCGen compatible) and legacy JSON.
  /// Reconstructs live object references via [loadedDataSet] if available.
  static Future<CharacterFacadeImpl?> load(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) return null;
      final content = await file.readAsString();
      final dataset = loadedDataSet.value;

      CharacterFacadeImpl character;
      if (PCGCharacterIO.isPCGFormat(content)) {
        // Native PCGen PCG v2 format
        character = PCGCharacterIO.read(content, dataset: dataset);
      } else {
        // Legacy JSON format (older saves from this app)
        try {
          final json = jsonDecode(content) as Map<String, dynamic>;
          character = CharacterFacadeImpl.fromJson(json);
          character.restoreFromDataset(dataset);
        } catch (_) {
          print('CharacterFileIO.load: unrecognised format in $path');
          return null;
        }
      }

      character.setFilePath(path);
      return character;
    } catch (e) {
      print('CharacterFileIO.load error: $e');
      return null;
    }
  }

  /// List all saved character files (.pcg and .json) ordered newest-first.
  static Future<List<File>> listSaved() async {
    try {
      final dir = await _getCharDir();
      return dir
          .listSync()
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.pcg') || f.path.endsWith('.json'))
          .toList()
        ..sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    } catch (_) {
      return [];
    }
  }

  static Future<String> getCharDir() async =>
      (await _getCharDir()).path;
}
