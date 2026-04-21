// Translation of pcgen.gui2.util.table.Row

/// Represents a single row of data in a table model.
abstract class Row {
  /// Returns the value at the given column index.
  dynamic getValueAt(int column);
  /// Sets the value at the given column index.
  void setValueAt(dynamic value, int column);
  /// Returns the number of columns in this row.
  int getColumnCount();
}
