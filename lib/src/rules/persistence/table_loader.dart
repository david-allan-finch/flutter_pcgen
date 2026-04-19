// Copyright PCGen authors.
//
// Translation of pcgen.rules.persistence.TableLoader

import '../../persistence/lst/lst_line_file_loader.dart';
import '../../rules/context/load_context.dart';

/// Loads CSV-like table LST files into DataTable objects.
///
/// A table file is delimited by STARTTABLE:/ENDTABLE: markers. The section
/// between them contains: (1) a column-name row, (2) a column-format row,
/// and (3) one or more data rows.
///
/// Translation of pcgen.rules.persistence.TableLoader.
class TableLoader extends LstLineFileLoader {
  /// Empty-line pattern: only whitespace, commas, or quote characters.
  static final RegExp _empty = RegExp(r'^[\s,"]+$');

  /// Current state machine processor for the active file.
  _LineProcessor _processor = const _ExpectStartTable();

  @override
  Future<void> loadLstFiles(LoadContext context, List<dynamic> fileList) async {
    // Reset processor so prior file errors do not contaminate the next file.
    _processor = const _ExpectStartTable();
    await super.loadLstFiles(context, fileList);
    if (_processor is! _ExpectStartTable) {
      print('ERROR: Did not find final ENDTABLE: entry in processed file');
    }
  }

  @override
  void parseLine(LoadContext context, String lstLine, Uri sourceUri) {
    // Skip comments.
    if (lstLine.startsWith('#') || lstLine.startsWith('"#')) return;
    // Skip empty lines.
    if (_empty.hasMatch(lstLine)) return;
    _processor = _processor.parseLine(context, lstLine, sourceUri);
  }
}

// ---------------------------------------------------------------------------
// State-machine processors
// ---------------------------------------------------------------------------

/// Base interface for a state-machine step.
abstract interface class _LineProcessor {
  _LineProcessor parseLine(LoadContext context, String lstLine, Uri sourceUri);
}

/// Unescapes a CSV-quoted entry and trims whitespace.
String _unescape(String entry) {
  String s = entry.trim();
  if (s.startsWith('"') && s.endsWith('"')) {
    s = s.substring(1, s.length - 1).replaceAll('""', '"');
  }
  return s.trim();
}

/// Splits a line by commas while respecting double-quote groupings.
List<String> _splitCsv(String line) {
  // Naive split that does not handle embedded newlines (acceptable for PCGen).
  final result = <String>[];
  final buf = StringBuffer();
  bool inQuote = false;
  for (int i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      if (inQuote && i + 1 < line.length && line[i + 1] == '"') {
        buf.write('"');
        i++;
      } else {
        inQuote = !inQuote;
        buf.write(ch);
      }
    } else if (ch == ',' && !inQuote) {
      result.add(buf.toString());
      buf.clear();
    } else {
      buf.write(ch);
    }
  }
  result.add(buf.toString());
  return result;
}

/// Waits for a STARTTABLE: line to begin a new table definition.
class _ExpectStartTable implements _LineProcessor {
  const _ExpectStartTable();

  @override
  _LineProcessor parseLine(LoadContext context, String lstLine, Uri sourceUri) {
    final parts = _splitCsv(lstLine);
    final first = _unescape(parts.first);
    if (first.startsWith('STARTTABLE:')) {
      final tableName = first.substring(11);
      // TODO: create DataTable in context.getReferenceContext()
      //       when DataTable type is ported.
      return _ImportColumnNames(tableName);
    }
    print('ERROR: Expected STARTTABLE: entry, but found: $lstLine in $sourceUri');
    return this;
  }
}

/// Reads the column-name row of a table.
class _ImportColumnNames implements _LineProcessor {
  final String tableName;

  const _ImportColumnNames(this.tableName);

  @override
  _LineProcessor parseLine(LoadContext context, String lstLine, Uri sourceUri) {
    final parts = _splitCsv(lstLine);
    final columnNames = <String>[];
    for (final part in parts) {
      final name = _unescape(part);
      if (name.isEmpty) continue;
      if (name.startsWith('STARTTABLE:') || name.startsWith('ENDTABLE:')) {
        print('ERROR: Unexpected $name while reading column names for '
            '$tableName in $sourceUri');
        return _ExpectStartTable();
      }
      columnNames.add(name);
    }
    return _ImportColumnFormats(tableName, columnNames);
  }
}

/// Reads the column-format row of a table (one format per column).
class _ImportColumnFormats implements _LineProcessor {
  final String tableName;
  final List<String> columnNames;

  const _ImportColumnFormats(this.tableName, this.columnNames);

  @override
  _LineProcessor parseLine(LoadContext context, String lstLine, Uri sourceUri) {
    final parts = _splitCsv(lstLine);
    final formats = <String>[];
    for (final part in parts) {
      final fmt = _unescape(part);
      if (fmt.isEmpty) continue;
      if (fmt.startsWith('STARTTABLE:') || fmt.startsWith('ENDTABLE:')) {
        print('ERROR: Unexpected $fmt while reading column formats for '
            '$tableName in $sourceUri');
        return _ExpectStartTable();
      }
      formats.add(fmt);
    }
    if (formats.length != columnNames.length) {
      print('ERROR: Table $tableName had different numbers of column names '
          '(${columnNames.length}) and formats (${formats.length}) in $sourceUri');
    }
    // TODO: register TableColumn objects in context when ported.
    return _ImportData(tableName, columnNames, formats);
  }
}

/// Reads data rows for a table until ENDTABLE: is encountered.
class _ImportData implements _LineProcessor {
  final String tableName;
  final List<String> columnNames;
  final List<String> columnFormats;
  final List<List<String>> rows = [];

  _ImportData(this.tableName, this.columnNames, this.columnFormats);

  @override
  _LineProcessor parseLine(LoadContext context, String lstLine, Uri sourceUri) {
    final parts = _splitCsv(lstLine);
    if (parts.isNotEmpty) {
      final first = _unescape(parts.first);
      if (first.startsWith('STARTTABLE:')) {
        print('ERROR: STARTTABLE: found before ENDTABLE: for $tableName '
            'in $sourceUri');
        return _ExpectStartTable();
      }
      if (first.startsWith('ENDTABLE:')) {
        if (rows.isEmpty) {
          print('ERROR: Table $tableName had no data in $sourceUri');
        }
        // TODO: finalise (trim) DataTable in context when ported.
        return const _ExpectStartTable();
      }
    }
    // Collect data row.
    final row = parts.map(_unescape).toList();
    rows.add(row);
    // TODO: convert each cell via its FormatManager and add to DataTable.
    return this;
  }
}
