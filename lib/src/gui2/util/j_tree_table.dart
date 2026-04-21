// Translation of pcgen.gui2.util.JTreeTable

import 'package:flutter/material.dart';

import 'treetable/tree_table_model.dart';
import 'treetable/tree_table_node.dart';
import 'tree_column_cell_renderer.dart';

/// A combined tree-and-table widget. The first column renders as an
/// expandable/collapsible tree; subsequent columns render plain cell data.
/// This is the Flutter equivalent of the Swing JTreeTable.
class JTreeTable extends StatefulWidget {
  final TreeTableModel? treeTableModel;
  final double rowHeight;

  const JTreeTable({
    super.key,
    this.treeTableModel,
    this.rowHeight = 24.0,
  });

  @override
  State<JTreeTable> createState() => JTreeTableState();
}

class JTreeTableState extends State<JTreeTable> {
  TreeTableModel? _model;
  Set<TreeTableNode> _expanded = {};
  TreeTableNode? _selected;

  @override
  void initState() {
    super.initState();
    _model = widget.treeTableModel;
  }

  @override
  void didUpdateWidget(JTreeTable old) {
    super.didUpdateWidget(old);
    if (widget.treeTableModel != old.treeTableModel) {
      setState(() {
        _model = widget.treeTableModel;
        _expanded = {};
        _selected = null;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final model = _model;
    if (model == null) return const SizedBox.shrink();

    final root = model.getRoot() as TreeTableNode?;
    final flatRows = _flatten(root, 0);
    final colCount = model.getColumnCount();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          // Header row
          Row(
            children: List.generate(colCount, (c) {
              return SizedBox(
                width: c == 0 ? 200 : 120,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    model.getColumnName(c) ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ),
          const Divider(height: 1),
          // Data rows
          ...flatRows.map((flat) {
            final isSelected = _selected == flat.node;
            return GestureDetector(
              onTap: () => setState(() => _selected = flat.node),
              child: Container(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
                height: widget.rowHeight,
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
                                  backgroundColor: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : null,
                                  isSelected: isSelected,
                                  isLeaf: flat.node.isLeaf(),
                                  isExpanded: flat.expanded,
                                  child: Text(
                                    flat.node.getValueAt(0)?.toString() ?? '',
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
                        padding: const EdgeInsets.symmetric(horizontal: 4),
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
          }),
        ],
      ),
    );
  }
}

class _FlatRow {
  final TreeTableNode node;
  final int depth;
  final bool expanded;

  const _FlatRow({
    required this.node,
    required this.depth,
    required this.expanded,
  });
}
