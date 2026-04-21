// Translation of pcgen.gui2.filter.FilteredListFacadeTableModel

import 'package:flutter/foundation.dart';
import 'filtered_list_facade.dart';

/// Table model backed by a FilteredListFacade.
class FilteredListFacadeTableModel<E> extends ChangeNotifier {
  final FilteredListFacade<E> _facade;
  final List<String> _columnNames;
  final dynamic Function(E element, int column) _getValue;

  FilteredListFacadeTableModel({
    required FilteredListFacade<E> facade,
    required List<String> columnNames,
    required dynamic Function(E element, int column) getValue,
  })  : _facade = facade,
        _columnNames = columnNames,
        _getValue = getValue {
    _facade.addListener(notifyListeners);
  }

  int get rowCount => _facade.getSize();
  int get columnCount => _columnNames.length;
  String getColumnName(int column) => _columnNames[column];

  dynamic getValueAt(int row, int column) {
    if (row < 0 || row >= rowCount) return null;
    return _getValue(_facade.getElementAt(row), column);
  }

  E getElementAt(int row) => _facade.getElementAt(row);

  @override
  void dispose() {
    _facade.removeListener(notifyListeners);
    super.dispose();
  }
}
