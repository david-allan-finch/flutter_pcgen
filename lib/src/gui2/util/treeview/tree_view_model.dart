// Translation of pcgen.gui2.util.treeview.TreeViewModel

import 'tree_view.dart';
import '../../facade/util/list_facade.dart';

/// Model that manages a set of TreeViews and a backing ListFacade.
abstract class TreeViewModel<T> {
  ListFacade<T> getDataModel();
  List<TreeView<T>> getTreeViews();
  List<dynamic> getColumns();
  dynamic getData(T element, int column);
  TreeView<T> getDefaultTreeView();
}
