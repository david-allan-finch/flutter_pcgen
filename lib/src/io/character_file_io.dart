// Character file save/load — stores characters as JSON .pcg files.

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';

class CharacterFileIO {
  static Future<Directory> _getCharDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'PCGen', 'characters'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Save [character] to disk. The filename is derived from the character name.
  /// Returns the path written, or null on error.
  static Future<String?> save(CharacterFacadeImpl character) async {
    try {
      final dir = await _getCharDir();
      final name = character.getName().isEmpty ? 'unnamed' : character.getName();
      final safeName = name.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final file = File(p.join(dir.path, '$safeName.pcg'));
      final json = jsonEncode(character.toJson());
      await file.writeAsString(json);
      character.setFilePath(file.path);
      return file.path;
    } catch (e) {
      print('CharacterFileIO.save error: $e');
      return null;
    }
  }

  /// Save [character] to [path].
  static Future<bool> saveAs(CharacterFacadeImpl character, String path) async {
    try {
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(character.toJson()));
      character.setFilePath(path);
      return true;
    } catch (e) {
      print('CharacterFileIO.saveAs error: $e');
      return false;
    }
  }

  /// Load a character from [path]. Returns null on error.
  static Future<CharacterFacadeImpl?> load(String path) async {
    try {
      final file = File(path);
      if (!file.existsSync()) return null;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final character = CharacterFacadeImpl.fromJson(json);
      character.setFilePath(path);
      return character;
    } catch (e) {
      print('CharacterFileIO.load error: $e');
      return null;
    }
  }

  /// List all saved .pcg files in the character directory.
  static Future<List<File>> listSaved() async {
    try {
      final dir = await _getCharDir();
      return dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.pcg'))
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    } catch (_) {
      return [];
    }
  }

  static Future<String> getCharDir() async =>
      (await _getCharDir()).path;
}
