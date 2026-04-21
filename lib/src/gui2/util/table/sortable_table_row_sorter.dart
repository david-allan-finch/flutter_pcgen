// Translation of pcgen.gui2.util.table.SortableTableRowSorter

/// Row sorter for sortable table models.
class SortableTableRowSorter<T> {
  final SortableTableModelBase _model;
  String? _sortKey;
  bool _ascending = true;
  List<int> _sortOrder = [];

  SortableTableRowSorter(this._model);

  void setSortKey(String column, {bool ascending = true}) {
    _sortKey = column;
    _ascending = ascending;
    _updateSortOrder();
  }

  void _updateSortOrder() {
    _sortOrder = List.generate(_model.rowCount, (i) => i);
    if (_sortKey != null) {
      _sortOrder.sort((a, b) {
        final va = _model.getValueAt(a, _sortKey!);
        final vb = _model.getValueAt(b, _sortKey!);
        int cmp = _compare(va, vb);
        return _ascending ? cmp : -cmp;
      });
    }
  }

  int _compare(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    if (a is Comparable) return a.compareTo(b);
    return a.toString().compareTo(b.toString());
  }

  int convertRowIndexToModel(int viewIndex) {
    if (_sortOrder.isEmpty || viewIndex >= _sortOrder.length) return viewIndex;
    return _sortOrder[viewIndex];
  }

  int convertRowIndexToView(int modelIndex) {
    return _sortOrder.indexOf(modelIndex);
  }
}

abstract class SortableTableModelBase {
  int get rowCount;
  dynamic getValueAt(int row, String column);
}
