// Translation of pcgen.gui2.tabs.summary.LanguageTableModel

import 'package:flutter/foundation.dart';

/// Table model for the languages list on the Summary tab.
class LanguageTableModel extends ChangeNotifier {
  static const List<String> columnNames = ['Language', 'Source'];

  final List<_LanguageRow> _rows = [];

  int get rowCount => _rows.length;
  int get columnCount => columnNames.length;

  dynamic getValue(int row, int col) {
    if (row < 0 || row >= _rows.length) return null;
    final r = _rows[row];
    switch (col) {
      case 0: return r.name;
      case 1: return r.source;
      default: return null;
    }
  }

  void setLanguages(List<({String name, String source})> languages) {
    _rows.clear();
    for (final l in languages) {
      _rows.add(_LanguageRow(name: l.name, source: l.source));
    }
    notifyListeners();
  }

  void clear() {
    _rows.clear();
    notifyListeners();
  }
}

class _LanguageRow {
  final String name;
  final String source;
  _LanguageRow({required this.name, required this.source});
}
