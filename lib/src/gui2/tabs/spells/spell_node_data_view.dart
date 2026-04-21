//
// Missing License Header, Copyright 2016 (C) Andrew Maitland <amaitland@users.sourceforge.net>
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
// Translation of pcgen.gui2.tabs.spells.SpellNodeDataView

import 'package:flutter_pcgen/src/gui2/util/treeview/data_view.dart';
import 'package:flutter_pcgen/src/gui2/util/treeview/data_view_column.dart';
import 'package:flutter_pcgen/src/gui2/util/treeview/default_data_view_column.dart';

/// DataView implementation for spell nodes in the spell tree table.
class SpellNodeDataView implements DataView<Map<String, dynamic>> {
  static final List<DataViewColumn> _columns = [
    DefaultDataViewColumn('Spell'),
    DefaultDataViewColumn('School'),
    DefaultDataViewColumn('Subschool'),
    DefaultDataViewColumn('Descriptor'),
    DefaultDataViewColumn('Components'),
    DefaultDataViewColumn('Cast Time'),
    DefaultDataViewColumn('Range'),
    DefaultDataViewColumn('Target/Area'),
    DefaultDataViewColumn('Duration'),
    DefaultDataViewColumn('Save'),
    DefaultDataViewColumn('SR'),
    DefaultDataViewColumn('Source'),
  ];

  static const List<String> _keys = [
    'name', 'school', 'subschool', 'descriptor',
    'components', 'castTime', 'range', 'target',
    'duration', 'save', 'sr', 'source',
  ];

  @override
  List<DataViewColumn> get columns => _columns;

  @override
  dynamic getValue(Map<String, dynamic> item, int column) {
    if (column < 0 || column >= _keys.length) return null;
    return item[_keys[column]];
  }
}
