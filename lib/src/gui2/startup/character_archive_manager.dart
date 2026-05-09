// CharacterArchiveManager — export/import character collections as .pcgch files.
//
// .pcgch format: a zip file containing:
//   characters.json  — CharacterArchiveMetadata (summary of included characters)
//   *.pcg            — individual character files in PCG v2 format

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pcgen/src/gui2/startup/pack_metadata.dart';
import 'package:flutter_pcgen/src/version.dart';

class CharacterArchiveManager {
  // ── Character directory ───────────────────────────────────────────────────

  static Future<Directory> get charDir async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'PCGen', 'characters'));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  // ── Export ────────────────────────────────────────────────────────────────

  /// Export [pcgFiles] (or all .pcg files if null) to a .pcgch archive.
  /// Returns the path of the created archive.
  Future<String> export({
    List<File>? pcgFiles,
    String? outputPath,
    void Function(double progress, String status)? onProgress,
  }) async {
    // Gather files
    final files = pcgFiles ?? await _allPcgFiles();
    if (files.isEmpty) throw Exception('No character files to export');

    // Build metadata
    final summaries = <CharacterSummary>[];
    for (final f in files) {
      summaries.add(_summariseFile(f));
    }
    final meta = CharacterArchiveMetadata(
      version: '1.0.0',
      appVersion: kBuildVersion,
      exportDate: _isoDate(DateTime.now()),
      characters: summaries,
    );

    // Determine output path
    final outPath = outputPath ?? await _defaultExportPath();
    final archive = Archive();

    // Add metadata
    final metaBytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(meta.toJson()),
    );
    archive.addFile(ArchiveFile('characters.json', metaBytes.length, metaBytes));

    // Add PCG files
    for (var i = 0; i < files.length; i++) {
      final f = files[i];
      onProgress?.call(i / files.length, 'Adding ${p.basename(f.path)}…');
      final bytes = await f.readAsBytes();
      archive.addFile(ArchiveFile(p.basename(f.path), bytes.length, bytes));
    }

    // Write zip
    onProgress?.call(null, 'Writing archive…');
    final outFile = File(outPath);
    await outFile.parent.create(recursive: true);
    final encoder = ZipEncoder();
    final outBytes = encoder.encode(archive);
    if (outBytes != null) await outFile.writeAsBytes(outBytes);

    onProgress?.call(1.0, 'Export complete');
    return outPath;
  }

  // ── Preview ───────────────────────────────────────────────────────────────

  /// Read metadata from a .pcgch file without extracting characters.
  Future<CharacterArchiveMetadata?> readMetadata(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final entry = archive.findFile('characters.json');
      if (entry == null) return null;
      final json = jsonDecode(utf8.decode(entry.content as List<int>));
      return CharacterArchiveMetadata.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Import ────────────────────────────────────────────────────────────────

  /// Extract all .pcg files from [filePath] into the characters directory.
  /// Returns the list of imported character names.
  Future<List<String>> import(
    String filePath, {
    bool overwrite = false,
    void Function(double? progress, String status)? onProgress,
  }) async {
    onProgress?.call(null, 'Reading archive…');
    final bytes = await File(filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final dest = await charDir;
    final imported = <String>[];

    final pcgFiles = archive.files
        .where((f) => f.isFile && f.name.endsWith('.pcg'))
        .toList();

    for (var i = 0; i < pcgFiles.length; i++) {
      final entry = pcgFiles[i];
      onProgress?.call(i / pcgFiles.length, 'Importing ${entry.name}…');
      final outFile = File(p.join(dest.path, entry.name));
      if (outFile.existsSync() && !overwrite) {
        // Avoid overwriting: add suffix
        final base = p.basenameWithoutExtension(entry.name);
        final renamed = File(p.join(dest.path, '${base}_imported.pcg'));
        await renamed.writeAsBytes(entry.content as List<int>);
        imported.add(base);
      } else {
        await outFile.writeAsBytes(entry.content as List<int>);
        imported.add(p.basenameWithoutExtension(entry.name));
      }
    }

    onProgress?.call(1.0, 'Imported ${imported.length} character(s)');
    return imported;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<List<File>> _allPcgFiles() async {
    final dir = await charDir;
    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.pcg'))
        .toList();
  }

  CharacterSummary _summariseFile(File f) {
    // Parse just enough from the PCG file to fill the summary.
    // PCG files are text; we scan for key lines.
    String name = p.basenameWithoutExtension(f.path);
    String race = '';
    String classes = '';
    int level = 0;

    try {
      final lines = f.readAsLinesSync();
      for (final line in lines) {
        if (line.startsWith('CHARACTERNAME:')) name = line.substring(14).trim();
        if (line.startsWith('RACE:')) race = line.substring(5).trim();
        if (line.startsWith('CLASS:')) {
          // CLASS:Fighter=4 CLASS:Wizard=3 ...
          final parts = line.split('\t');
          final clsList = <String>[];
          for (final part in parts) {
            if (part.startsWith('CLASS:')) {
              final inner = part.substring(6);
              final eq = inner.indexOf('=');
              if (eq > 0) {
                final cn = inner.substring(0, eq);
                final lv = int.tryParse(inner.substring(eq + 1)) ?? 0;
                clsList.add('$cn $lv');
                level += lv;
              }
            }
          }
          if (clsList.isNotEmpty) classes = clsList.join('/');
        }
      }
    } catch (_) {}

    return CharacterSummary(
      file: p.basename(f.path),
      name: name,
      race: race,
      classes: classes,
      level: level,
    );
  }

  Future<String> _defaultExportPath() async {
    final docs = await getApplicationDocumentsDirectory();
    final date = _isoDate(DateTime.now());
    return p.join(docs.path, 'PCGen', 'characters_$date.pcgch');
  }

  String _isoDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
