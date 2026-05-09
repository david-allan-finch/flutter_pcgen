// DataManager — installs and manages .pcglst data packs on mobile platforms.
//
// .pcglst format: a zip file containing:
//   pack.json        — PackMetadata (name, version, gameMode, etc.)
//   system/          — game mode files (optional)
//   data/            — LST source files (optional)
//
// Installed packs are tracked in <baseDir>/installed_packs.json.
// All packs are merged into the single <baseDir> tree so ConfigurationSettings
// can point @system and @data at it without needing to know about pack structure.

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pcgen/src/gui2/startup/pack_metadata.dart';
import 'package:flutter_pcgen/src/system/configuration_settings.dart';

class DataManager {
  // ── Built-in catalogue ────────────────────────────────────────────────────
  // Update these URLs when you publish releases.

  static const List<CatalogueEntry> catalogue = [
    CatalogueEntry(
      metadata: PackMetadata(
        id: 'srd35',
        name: '3.5e SRD',
        version: '1.0.0',
        gameMode: '35e',
        description: 'D&D 3.5 System Reference Document — core rules and monsters',
        author: 'PCGen Community',
      ),
      url: 'https://github.com/david-allan-finch/flutter_pcgen/releases/download/pcglst-v1/srd35.pcglst',
      sizeMb: '~45 MB',
    ),
    CatalogueEntry(
      metadata: PackMetadata(
        id: 'pathfinder1e',
        name: 'Pathfinder 1e',
        version: '1.0.0',
        gameMode: 'Pathfinder',
        description: 'Pathfinder 1st Edition core rules',
        author: 'PCGen Community',
      ),
      url: 'https://github.com/david-allan-finch/flutter_pcgen/releases/download/pcglst-v1/pathfinder1e.pcglst',
      sizeMb: '~60 MB',
    ),
  ];

  // ── Paths ─────────────────────────────────────────────────────────────────

  static Future<Directory> get baseDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/pcgen');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  static Future<File> get _manifestFile async =>
      File('${(await baseDir).path}/installed_packs.json');

  // ── Installed pack management ─────────────────────────────────────────────

  Future<List<InstalledPack>> getInstalledPacks() async {
    try {
      final f = await _manifestFile;
      if (!f.existsSync()) return [];
      final json = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      return (json['installedPacks'] as List? ?? [])
          .map((e) => InstalledPack.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveInstalledPacks(List<InstalledPack> packs) async {
    final f = await _manifestFile;
    await f.writeAsString(jsonEncode({
      'installedPacks': packs.map((p) => p.toJson()).toList(),
    }));
  }

  Future<bool> isPackInstalled(String id) async {
    final installed = await getInstalledPacks();
    return installed.any((p) => p.metadata.id == id);
  }

  Future<void> removePack(String id) async {
    final packs = await getInstalledPacks();
    await _saveInstalledPacks(packs.where((p) => p.metadata.id != id).toList());
    // Note: we don't delete the extracted files because multiple packs share
    // the same directory tree. A full reinstall is needed if files must be removed.
  }

  // ── Ready check ───────────────────────────────────────────────────────────

  /// True if at least one data pack is installed and the system/ dir exists.
  Future<bool> isDataReady() async {
    final packs = await getInstalledPacks();
    if (packs.isEmpty) return false;
    final base = await baseDir;
    return Directory('${base.path}/system').existsSync() ||
           Directory('${base.path}/data').existsSync();
  }

  /// Sets ConfigurationSettings data root to our base directory.
  Future<void> configureDataRoot() async {
    final base = await baseDir;
    ConfigurationSettings.setDataRoot(base.path);
  }

  // ── Download + install from URL ───────────────────────────────────────────

  Future<void> downloadAndInstall(
    String url, {
    required void Function(double? progress, String status) onProgress,
  }) async {
    final base = await baseDir;
    final tmpFile = File('${base.path}/_download.pcglst');

    // Download
    onProgress(0.0, 'Connecting…');
    final request = http.Request('GET', Uri.parse(url));
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Download failed: HTTP ${response.statusCode}');
    }

    final total = response.contentLength ?? 0;
    int received = 0;
    final sink = tmpFile.openWrite();
    await for (final chunk in response.stream) {
      sink.add(chunk);
      received += chunk.length;
      final frac = total > 0 ? received / total * 0.8 : null;
      onProgress(frac, 'Downloading… ${_mb(received)}${total > 0 ? " / ${_mb(total)}" : ""} MB');
    }
    await sink.flush();
    await sink.close();

    // Install from the downloaded file
    await installFromFile(tmpFile.path, onProgress: onProgress);
    await tmpFile.delete();
  }

  // ── Install from local .pcglst file ──────────────────────────────────────

  Future<PackMetadata> installFromFile(
    String filePath, {
    required void Function(double? progress, String status) onProgress,
  }) async {
    onProgress(null, 'Reading pack…');
    final base = await baseDir;

    // Read pack.json from zip without full extraction first
    final meta = await readPackMetadata(filePath);
    if (meta == null) throw Exception('Invalid .pcglst: missing pack.json');

    onProgress(null, 'Installing ${meta.name}…');
    await _extractZip(File(filePath), base);

    // Update manifest
    final packs = await getInstalledPacks();
    packs.removeWhere((p) => p.metadata.id == meta.id); // replace if updating
    packs.add(InstalledPack(metadata: meta, installedAt: DateTime.now()));
    await _saveInstalledPacks(packs);

    onProgress(1.0, 'Installed ${meta.name}');
    return meta;
  }

  /// Reads only the pack.json from a .pcglst zip without full extraction.
  Future<PackMetadata?> readPackMetadata(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final entry = archive.findFile('pack.json');
      if (entry == null) return null;
      final json = jsonDecode(utf8.decode(entry.content as List<int>));
      return PackMetadata.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _extractZip(File zipFile, Directory dest) async {
    final inputStream = InputFileStream(zipFile.path);
    final archive = ZipDecoder().decodeBuffer(inputStream);
    for (final file in archive) {
      if (file.name == 'pack.json') continue; // metadata handled separately
      final outPath = '${dest.path}/${file.name}';
      if (file.isFile) {
        final outFile = File(outPath);
        await outFile.create(recursive: true);
        final outStream = OutputFileStream(outPath);
        file.writeContent(outStream);
        await outStream.close();
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }
    await inputStream.close();
  }

  String _mb(int bytes) => (bytes / 1048576).toStringAsFixed(1);
}
