// DataManager — handles downloading and extracting PCGen system/data files
// on platforms where they cannot be shipped inside the app bundle (Android, iOS).
//
// Usage:
//   final mgr = DataManager();
//   if (!await mgr.isDataReady()) {
//     // show DataDownloadScreen
//   } else {
//     mgr.configureDataRoot();  // point ConfigurationSettings at the local copy
//   }

import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pcgen/src/system/configuration_settings.dart';

class DataManager {
  // ── Configuration ──────────────────────────────────────────────────────────

  /// URL of the zip that contains system/ and data/ directories.
  /// Update this to point at your GitHub release or CDN.
  static const String dataZipUrl =
      'https://github.com/david-allan-finch/flutter_pcgen/releases/download/data-v1/pcgen-data.zip';

  /// Version token stored in <dataRoot>/pcgen_data_version.txt.
  /// Bump this to force a re-download when the data changes.
  static const String expectedDataVersion = '1.0.0';

  // ── Internal paths ─────────────────────────────────────────────────────────

  Future<Directory> get _baseDir async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/pcgen');
  }

  Future<File> get _versionFile async =>
      File('${(await _baseDir).path}/pcgen_data_version.txt');

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns true if locally extracted data is present and up-to-date.
  Future<bool> isDataReady() async {
    try {
      final vf = await _versionFile;
      if (!vf.existsSync()) return false;
      final version = (await vf.readAsString()).trim();
      if (version != expectedDataVersion) return false;
      // Quick sanity: check system/ and data/ exist.
      final base = await _baseDir;
      final systemOk = Directory('${base.path}/system').existsSync();
      final dataOk   = Directory('${base.path}/data').existsSync();
      return systemOk && dataOk;
    } catch (_) {
      return false;
    }
  }

  /// Sets [ConfigurationSettings.dataRoot] to the local data directory.
  /// Call this after confirming [isDataReady] is true.
  Future<void> configureDataRoot() async {
    final base = await _baseDir;
    ConfigurationSettings.setDataRoot(base.path);
  }

  /// Downloads the data zip from [dataZipUrl] and extracts it.
  ///
  /// [onProgress] receives values 0.0–1.0 during download, then null during
  /// extraction (indeterminate), then 1.0 when complete.
  Future<void> downloadAndExtract({
    required void Function(double? progress, String status) onProgress,
  }) async {
    final base = await _baseDir;
    await base.create(recursive: true);
    final zipFile = File('${base.path}/pcgen-data.zip');

    // ── Download ──────────────────────────────────────────────────────────────
    onProgress(0.0, 'Connecting…');
    final request = http.Request('GET', Uri.parse(dataZipUrl));
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Download failed: HTTP ${response.statusCode}');
    }

    final total = response.contentLength ?? 0;
    int received = 0;
    final sink = zipFile.openWrite();

    await for (final chunk in response.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (total > 0) {
        onProgress(received / total * 0.8, // 0–80% = download
            'Downloading… ${_mb(received)} / ${_mb(total)} MB');
      } else {
        onProgress(null, 'Downloading… ${_mb(received)} MB');
      }
    }
    await sink.flush();
    await sink.close();

    // ── Extract ───────────────────────────────────────────────────────────────
    onProgress(null, 'Extracting…');
    await _extractZip(zipFile, base);

    // ── Finalise ──────────────────────────────────────────────────────────────
    await (await _versionFile).writeAsString(expectedDataVersion);
    await zipFile.delete(); // free space
    onProgress(1.0, 'Complete');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _extractZip(File zipFile, Directory dest) async {
    // Use streaming extraction to avoid loading the whole zip into RAM.
    final inputStream = InputFileStream(zipFile.path);
    final archive = ZipDecoder().decodeBuffer(inputStream);
    for (final file in archive) {
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
