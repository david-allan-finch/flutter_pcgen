// Copyright PCGen authors.
//
// Translation of pcgen.persistence.lst.utils.VariableReport

import 'dart:io';

/// Scans LST files for DEFINE: tokens and produces a variable-usage report.
///
/// Translation of pcgen.persistence.lst.utils.VariableReport.
class VariableReport {
  // ---------------------------------------------------------------------------
  // Report generation
  // ---------------------------------------------------------------------------

  /// Scans all LST files referenced by the loaded campaigns and builds a
  /// sorted list of [VarDefine] records.
  ///
  /// [lstFilePaths] is a flat list of absolute paths to all LST files to
  /// inspect.  Returns a map from game-mode name → sorted variable list,
  /// mirroring the Java data model.
  Future<Map<String, List<VarDefine>>> buildVarMap(
      Map<String, List<String>> gameModeFilePaths) async {
    final result = <String, List<VarDefine>>{};

    for (final entry in gameModeFilePaths.entries) {
      final gameMode = entry.key;
      final filePaths = entry.value;

      final varList = <VarDefine>[];
      final varCountMap = <String, int>{};
      final processed = <String>{};

      for (final path in filePaths) {
        if (processed.contains(path)) continue;
        final file = File(path);
        if (!file.existsSync()) continue;
        processed.add(path);
        await _processLstFile(varList, varCountMap, file);
      }

      varList.sort();
      result[gameMode] = varList;
    }

    return result;
  }

  Future<void> _processLstFile(
      List<VarDefine> varList,
      Map<String, int> varCountMap,
      File file) async {
    final lines = await file.readAsLines();
    final varUseMap = <String, String>{};

    for (final line in lines) {
      if (line.startsWith('###VAR:')) {
        // ###VAR:SomeVar<tab>USE:Explanation
        final parts = line.trim().split('\t');
        if (parts.length >= 2 && parts[1].startsWith('USE:')) {
          final varName = parts[0].substring(7);
          varUseMap[varName] = parts[1].substring(4);
        }
      } else if (!line.startsWith('#') && line.trim().isNotEmpty) {
        final tokens = line.split('\t');
        if (tokens.isEmpty) continue;
        final object = tokens[0];
        for (final tok in tokens) {
          if (tok.startsWith('DEFINE:')) {
            final define = tok.split(RegExp(r'[:|]'));
            if (define.length >= 2) {
              final varName = define[1];
              if (!varName.startsWith('LOCK.') &&
                  !varName.startsWith('UNLOCK.')) {
                varList.add(VarDefine(
                  varName: varName,
                  definingObject: object,
                  definingFile: file.path,
                  use: varUseMap[varName],
                ));
                varCountMap[varName] = (varCountMap[varName] ?? 0) + 1;
              }
            }
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Text report generation
  // ---------------------------------------------------------------------------

  /// Generates a plain-text summary report from [gameModeVarMap].
  static String generateTextReport(
      Map<String, List<VarDefine>> gameModeVarMap) {
    final sb = StringBuffer();
    sb.writeln('PCGen Variable Report');
    sb.writeln('Generated: ${DateTime.now()}');
    sb.writeln();

    for (final entry in gameModeVarMap.entries) {
      final gameMode = entry.key;
      final vars = entry.value;
      sb.writeln('Game Mode: $gameMode  (${vars.length} unique variables)');
      sb.writeln('-' * 60);
      for (final v in vars) {
        sb.write('  ${v.varName.padRight(40)} '
            '[${v.definingObject}] '
            '${v.definingFile}');
        if (v.use != null) sb.write('  -- ${v.use}');
        sb.writeln();
      }
      sb.writeln();
    }

    return sb.toString();
  }

  /// Generates a CSV-format report from [gameModeVarMap].
  static String generateCsvReport(
      Map<String, List<VarDefine>> gameModeVarMap) {
    final sb = StringBuffer();
    sb.writeln('GameMode,VarName,DefiningObject,DefiningFile,Use');
    for (final entry in gameModeVarMap.entries) {
      for (final v in entry.value) {
        sb.writeln('${_csvCell(entry.key)},'
            '${_csvCell(v.varName)},'
            '${_csvCell(v.definingObject)},'
            '${_csvCell(v.definingFile)},'
            '${_csvCell(v.use ?? "")}');
      }
    }
    return sb.toString();
  }

  static String _csvCell(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}

// ---------------------------------------------------------------------------
// Data class
// ---------------------------------------------------------------------------

/// A single variable definition found in an LST file.
class VarDefine implements Comparable<VarDefine> {
  final String varName;
  final String definingObject;
  final String definingFile;
  final String? use;

  const VarDefine({
    required this.varName,
    required this.definingObject,
    required this.definingFile,
    this.use,
  });

  @override
  int compareTo(VarDefine other) =>
      varName.toLowerCase().compareTo(other.varName.toLowerCase());

  @override
  bool operator ==(Object other) =>
      other is VarDefine &&
      varName == other.varName &&
      definingObject == other.definingObject;

  @override
  int get hashCode => varName.hashCode ^ definingObject.hashCode;

  @override
  String toString() =>
      'VarDefine[varName=$varName, definingObject=$definingObject, '
      'definingFile=$definingFile, use=$use]';
}

// ---------------------------------------------------------------------------
// Report format enum
// ---------------------------------------------------------------------------

enum ReportFormat {
  /// Human-readable plain-text report.
  text,

  /// CSV-formatted report suitable for spreadsheets.
  csv,
}
