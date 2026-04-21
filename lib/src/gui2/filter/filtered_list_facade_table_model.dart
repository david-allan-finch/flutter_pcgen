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
