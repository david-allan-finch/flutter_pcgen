// Translation of pcgen.gui2.util.treeview.DataViewColumn

/// Describes a single column in a DataView.
abstract class DataViewColumn {
  String getHeaderValue();
  Type getDataClass();
  bool isVisible();
  bool isEditable();
  double getPreferredWidth();
}
