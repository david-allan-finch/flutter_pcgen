//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.tabs.ability.CategoryTableModel

import 'package:flutter/foundation.dart';

/// Table model that tracks ability categories and their point pools.
class CategoryTableModel extends ChangeNotifier {
  final List<_CategoryEntry> _categories = [];

  int get rowCount => _categories.length;

  static const List<String> columnNames = ['Category', 'Pool', 'Used', 'Remaining'];

  String? getValue(int row, int col) {
    if (row < 0 || row >= _categories.length) return null;
    final e = _categories[row];
    switch (col) {
      case 0: return e.name;
      case 1: return e.pool.toString();
      case 2: return e.used.toString();
      case 3: return (e.pool - e.used).toString();
      default: return null;
    }
  }

  void setCategories(List<({String name, int pool, int used})> cats) {
    _categories.clear();
    for (final c in cats) {
      _categories.add(_CategoryEntry(c.name, c.pool, c.used));
    }
    notifyListeners();
  }

  void clear() {
    _categories.clear();
    notifyListeners();
  }
}

class _CategoryEntry {
  final String name;
  final int pool;
  final int used;
  _CategoryEntry(this.name, this.pool, this.used);
}
