// Translation of pcgen.gui2.filter.FilteredTreeViewTable

import 'package:flutter/material.dart';
import 'filtered_tree_view_model.dart';
import 'filter.dart';
import 'filter_bar.dart';

/// A widget that combines a FilterBar with a tree-view table.
class FilteredTreeViewTable<T> extends StatefulWidget {
  final FilteredTreeViewModel<T> model;

  const FilteredTreeViewTable({super.key, required this.model});

  @override
  State<FilteredTreeViewTable<T>> createState() =>
      _FilteredTreeViewTableState<T>();
}

class _FilteredTreeViewTableState<T>
    extends State<FilteredTreeViewTable<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilterBar<T>(
          onFilterChanged: (f) => widget.model.setFilter(f),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: widget.model,
            builder: (context, _) {
              final src = widget.model.getDataModel();
              final cols = widget.model.getColumns();
              final rows = <List<String>>[];
              for (int i = 0; i < src.getSize(); i++) {
                final el = src.getElementAt(i);
                rows.add(List.generate(cols.length,
                    (c) => widget.model.getData(el, c)?.toString() ?? ''));
              }
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: cols
                      .map((c) => DataColumn(label: Text(c.toString())))
                      .toList(),
                  rows: rows
                      .map((row) => DataRow(
                            cells: row
                                .map((cell) => DataCell(Text(cell)))
                                .toList(),
                          ))
                      .toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
