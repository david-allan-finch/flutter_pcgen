// Character file save/load — stores characters as JSON .pcg files.

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';

class CharacterFileIO {
  static Future<Directory> _getCharDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'PCGen', 'characters'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

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

  /// Save [character] to disk. Filename derives from the character name.
  /// Returns the path written, or null on error.
  static Future<String?> save(CharacterFacadeImpl character) async {
    try {
      final dir = await _getCharDir();
      final name =
          character.getName().trim().isEmpty ? 'unnamed' : character.getName().trim();
      final safeName = name.replaceAll(RegExp(r'[^\w\s\-]'), '_');
      final file = File(p.join(dir.path, '$safeName.pcg'));
      final json = jsonEncode(_sanitise(character.toJson()));
      await file.writeAsString(json, flush: true);
      character.setFilePath(file.path);
      return file.path;
    } catch (e) {
      print('CharacterFileIO.save error: $e');
      return null;
    }
  }

  /// Save [character] to an explicit [path].
  static Future<bool> saveAs(CharacterFacadeImpl character, String path) async {
    try {
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsString(
          jsonEncode(_sanitise(character.toJson())),
          flush: true);
      character.setFilePath(path);
      return true;
    } catch (e) {
      print('CharacterFileIO.saveAs error: $e');
      return false;
    }
  }

  /// Load a character from [path].
  /// Reconstructs live object references (race etc.) from [loadedDataSet] if
  /// available. Returns null on error.
  static Future<CharacterFacadeImpl?> load(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) return null;
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final character = CharacterFacadeImpl.fromJson(json);
      character.setFilePath(path);
      // Reconnect live game objects from the currently loaded dataset.
      character.restoreFromDataset(loadedDataSet.value);
      return character;
    } catch (e) {
      print('CharacterFileIO.load error: $e');
      return null;
    }
  }

  /// List all saved .pcg files ordered newest-first.
  static Future<List<File>> listSaved() async {
    try {
      final dir = await _getCharDir();
      return dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.pcg'))
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
