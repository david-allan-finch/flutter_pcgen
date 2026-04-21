// Translation of pcgen.gui2.util.treeview.DataView

/// Interface for objects that can provide display data for an item.
abstract class DataView<T> {
  List<dynamic> getColumns();
  dynamic getData(T element, int column);
  bool isLeaf(T element);
}
