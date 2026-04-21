// Translation of pcgen.gui2.util.treeview.TreeView

/// Interface for a tree view strategy: provides the path components
/// used to place an item in the tree.
abstract class TreeView<T> {
  String getViewName();
  List<dynamic> getPath(T element);
}
