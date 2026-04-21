//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.util.JTreeViewTable

import 'package:flutter/material.dart';

import '../../facade/util/list_facade.dart';
import '../../facade/util/event/list_event.dart';
import '../../facade/util/event/list_listener.dart';
import 'table/default_dynamic_table_column_model.dart';
import 'table/dynamic_table_column_model.dart';
import 'treeview/data_view.dart';
import 'treeview/data_view_column.dart';
import 'treeview/tree_view.dart';
import 'treeview/tree_view_model.dart';
import 'treeview/tree_view_table_model.dart';
import 'treetable/tree_table_node.dart';
import 'tree_column_cell_renderer.dart';
import 'j_table_menu_button.dart';

/// Flutter equivalent of JTreeViewTable. Uses a [TreeViewModel] to display
/// arbitrary objects as an expandable tree with optional extra data columns.
/// The corner button opens a menu for view selection and column visibility.
class JTreeViewTable<T> extends StatefulWidget {
  const JTreeViewTable({super.key});

  @override
  State<JTreeViewTable<T>> createState() => JTreeViewTableState<T>();
}

class JTreeViewTableState<T> extends State<JTreeViewTable<T>>
    implements ListListener<TreeView<T>> {
  TreeViewModel<T>? _viewModel;
  TreeViewTableModel<T>? _treeTableModel;
  DynamicTableColumnModel? _columnModel;
  TreeView<dynamic>? _selectedTreeView;

  final Set<TreeTableNode> _expanded = {};
  TreeTableNode? _selectedNode;

  void setTreeViewModel(TreeViewModel<T> viewModel) {
    _viewModel?.getTreeViews().removeListListener(this);
    _viewModel = viewModel;

    final DataView<T> dataView = viewModel.getDataView();
    final views = viewModel.getTreeViews();
    final int viewIdx = viewModel.getDefaultTreeViewIndex();
    final TreeView<dynamic> startView = views.getElementAt(viewIdx);

    final model = TreeViewTableModel<T>(dataView);
    model.setDataModel(viewModel.getDataModel());
    model.setSelectedTreeView(startView);

    _treeTableModel = model;
    _selectedTreeView = startView;
    _columnModel = _buildColumnModel(startView, dataView);

    viewModel.getTreeViews().addListListener(this);
    setState(() {});
  }

  DynamicTableColumnModel _buildColumnModel(
      TreeView<dynamic> view, DataView<T> dataView) {
    final cols = dataView.getDataColumns();
    // always-visible count = 1 (the tree column itself)
    final model = DefaultDynamicTableColumnModel(1);
    // tree view column is column 0 – represented by the model itself
    int colIdx = 1;
    for (final col in cols) {
      model.addColumn(_ColumnDef(colIdx++, col.getName()));
      if (col.getVisibility() != Visibility.initiallyInvisible) {
        model.setVisibleByIndex(colIdx - 1, true);
      }
    }
    return model;
  }

  void setTreeView(TreeView<dynamic> view) {
    _treeTableModel?.setSelectedTreeView(view);
    setState(() => _selectedTreeView = view);
  }

  TreeView<dynamic>? getSelectedTreeView() => _selectedTreeView;

  List<T> getSelectedData() {
    if (_selectedNode == null) return [];
    final obj = _selectedNode!.getValueAt(0);
    if (obj is T) return [obj];
    return [];
  }

  // ListListener for TreeView list changes
  @override
  void elementAdded(ListEvent<TreeView<T>> e) => setState(() {});
  @override
  void elementRemoved(ListEvent<TreeView<T>> e) => setState(() {});
  @override
  void elementsChanged(ListEvent<TreeView<T>> e) => setState(() {});
  @override
  void elementModified(ListEvent<TreeView<T>> e) {}

  List<_FlatRow> _flatten(TreeTableNode? node, int depth) {
    if (node == null) return [];
    final rows = <_FlatRow>[];
    for (int i = 0; i < node.getChildCount(); i++) {
      final child = node.getChildAt(i);
      if (child == null) continue;
      final expanded = _expanded.contains(child);
      rows.add(_FlatRow(node: child, depth: depth, expanded: expanded));
      if (expanded && !child.isLeaf()) {
        rows.addAll(_flatten(child, depth + 1));
      }
    }
    return rows;
  }

  List<PopupMenuEntry<dynamic>> _buildCornerMenu(BuildContext context) {
    final entries = <PopupMenuEntry<dynamic>>[];
    final vm = _viewModel;
    if (vm != null) {
      final views = vm.getTreeViews();
      for (int i = 0; i < views.getSize(); i++) {
        final view = views.getElementAt(i);
        entries.add(
          CheckedPopupMenuItem<dynamic>(
            value: view,
            checked: view == _selectedTreeView,
            onTap: () => setTreeView(view),
            child: Text(view.getViewName()),
          ),
        );
      }
      entries.add(const PopupMenuDivider());
    }
    final colModel = _columnModel;
    if (colModel != null) {
      for (final col in colModel.getAvailableColumns()) {
        final visible = colModel.isVisible(col);
        entries.add(
          CheckedPopupMenuItem<dynamic>(
            value: col,
            checked: visible,
            onTap: () => setState(() => colModel.setVisible(col, !visible)),
            child: Text(col.headerValue?.toString() ?? ''),
          ),
        );
      }
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final tableModel = _treeTableModel;
    if (tableModel == null) return const SizedBox.shrink();

    final root = tableModel.getRoot() as TreeTableNode?;
    final flatRows = _flatten(root, 0);
    final colCount = tableModel.getColumnCount();

    final hasMenu = (_viewModel?.getTreeViews().getSize() ?? 0) > 0 ||
        (_columnModel?.getAvailableColumns().isNotEmpty ?? false);

    return Column(
      children: [
        // Header
        Row(
          children: [
            ...List.generate(colCount, (c) {
              return SizedBox(
                width: c == 0 ? 200 : 120,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    tableModel.getColumnName(c) ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }),
            if (hasMenu)
              JTableMenuButton(itemBuilder: _buildCornerMenu),
          ],
        ),
        const Divider(height: 1),
        // Rows
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: flatRows.map((flat) {
                  final isSel = _selectedNode == flat.node;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedNode = flat.node),
                    child: Container(
                      color: isSel
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.transparent,
                      height: 24,
                      child: Row(
                        children: List.generate(colCount, (c) {
                          if (c == 0) {
                            return SizedBox(
                              width: 200,
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                    start: flat.depth * 16.0 + 4),
                                child: Row(
                                  children: [
                                    if (!flat.node.isLeaf())
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          if (flat.expanded) {
                                            _expanded.remove(flat.node);
                                          } else {
                                            _expanded.add(flat.node);
                                          }
                                        }),
                                        child: Icon(
                                          flat.expanded
                                              ? Icons.arrow_drop_down
                                              : Icons.arrow_right,
                                          size: 16,
                                        ),
                                      )
                                    else
                                      const SizedBox(width: 16),
                                    Expanded(
                                      child: TreeColumnCellRenderer(
                                        isSelected: isSel,
                                        isLeaf: flat.node.isLeaf(),
                                        isExpanded: flat.expanded,
                                        child: Text(
                                          flat.node.getValueAt(0)?.toString() ??
                                              '',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return SizedBox(
                            width: 120,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                flat.node.getValueAt(c)?.toString() ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FlatRow {
  final TreeTableNode node;
  final int depth;
  final bool expanded;
  const _FlatRow(
      {required this.node, required this.depth, required this.expanded});
}

/// A lightweight column descriptor used internally by [JTreeViewTableState].
class _ColumnDef {
  final int index;
  final String name;
  dynamic get headerValue => name;
  _ColumnDef(this.index, this.name);
}
