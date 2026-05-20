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

  /// Sync the currently loaded dataset's campaign names onto [character] so
  /// that write() can reproduce the full CAMPAIGN: header section.
  static void _syncCampaignNames(CharacterFacadeImpl character) {
    final dataset = loadedDataSet.value;
    if (dataset == null) return;
    final names = dataset.campaigns
        .map((c) => c.getDisplayName() as String? ?? c.getKeyName() as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    if (names.isNotEmpty) character.setActiveCampaignNames(names);
  }

  /// Save [character] to disk in PCG v2 format.
  /// Filename derives from the character name. Returns the path, or null on error.
  static Future<String?> save(CharacterFacadeImpl character) async {
    try {
      _syncCampaignNames(character);
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

  /// Save [character] to a new file with [suggestedName] (without extension).
  /// The UUID is preserved — this is a checkpoint of the same character, not a copy.
  /// Returns the path written, or null on failure.
  static Future<String?> saveNewVersion(
      CharacterFacadeImpl character, String suggestedName) async {
    try {
      _syncCampaignNames(character);
      final dir      = await _getCharDir();
      final safeName = suggestedName.trim().isEmpty
          ? character.getName().replaceAll(RegExp(r'[^\w\s\-]'), '_')
          : suggestedName.replaceAll(RegExp(r'[^\w\s\-.]'), '_');
      // Find a non-colliding filename
      var path = p.join(dir.path, '$safeName.pcg');
      var counter = 2;
      while (File(path).existsSync()) {
        path = p.join(dir.path, '${safeName}_$counter.pcg');
        counter++;
      }
      await File(path).writeAsString(PCGCharacterIO.write(character), flush: true);
      // Update the character's file path to point to the new file
      character.setFilePath(path);
      return path;
    } catch (e) {
      print('CharacterFileIO.saveNewVersion error: $e');
      return null;
    }
  }

  /// Save [character] to an explicit [path] in PCG v2 format.
  static Future<bool> saveAs(CharacterFacadeImpl character, String path) async {
    try {
      _syncCampaignNames(character);
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

  /// Re-save all .pcg character files whose game mode matches the current
  /// loaded dataset, updating their CAMPAIGN: headers to include all active
  /// source books. Returns counts of (migrated, skipped, failed).
  ///
  /// Call this once after loading the correct sources to fix character files
  /// that were saved before build-103 (which only wrote one CAMPAIGN: line).
  static Future<({int migrated, int skipped, int failed})> migrateAllCharacters() async {
    final dataset = loadedDataSet.value;
    if (dataset == null) return (migrated: 0, skipped: 0, failed: 0);
    final currentMode = dataset.gameModeStr.toLowerCase();

    int migrated = 0, skipped = 0, failed = 0;
    final files = await listSaved();
    for (final file in files.where((f) => f.path.endsWith('.pcg'))) {
      try {
        final content = await file.readAsString();
        final header = PCGCharacterIO.peekHeader(content);
        final fileMode = (header['gameMode'] ?? '').toLowerCase();
        // Only migrate files whose game mode matches the current dataset.
        if (fileMode.isNotEmpty && fileMode != currentMode) {
          skipped++;
          continue;
        }
        final character = await load(file.path);
        if (character == null) { failed++; continue; }
        _syncCampaignNames(character);
        final ok = await saveAs(character, file.path);
        if (ok) migrated++; else failed++;
      } catch (_) {
        failed++;
      }
    }
    return (migrated: migrated, skipped: skipped, failed: failed);
  }
}
