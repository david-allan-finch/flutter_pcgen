// Translation of pcgen.gui2.util.table.DynamicTableColumnModel

/// Interface for a table column model that supports dynamic show/hide of columns.
abstract class DynamicTableColumnModel {
  void setColumnVisible(dynamic column, bool visible);
  bool isColumnVisible(dynamic column);
  List<dynamic> getColumns({bool includeHidden = false});
  void addColumnModelListener(dynamic listener);
  void removeColumnModelListener(dynamic listener);
}
