//
// Copyright 2010 (C) Connor Petty <cpmeister@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.gui2.tabs.summary.LanguageTableModel

import 'package:flutter/foundation.dart';

/// Table model for the languages list on the Summary tab.
class LanguageTableModel extends ChangeNotifier {
  // ignore: unused_field
  final dynamic _character;

  LanguageTableModel([this._character]);

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

  /// Number of languages in the list.
  int get languageCount => _rows.length;

  /// Returns the language name at [index].
  String languageName(int index) {
    if (index < 0 || index >= _rows.length) return '';
    return _rows[index].name;
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
