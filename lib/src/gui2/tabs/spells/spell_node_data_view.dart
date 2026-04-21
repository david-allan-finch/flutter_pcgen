// Translation of pcgen.gui2.tabs.spells.SpellNodeDataView

import '../../util/treeview/data_view.dart';
import '../../util/treeview/data_view_column.dart';
import '../../util/treeview/default_data_view_column.dart';

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
