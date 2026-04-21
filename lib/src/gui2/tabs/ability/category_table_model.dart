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
