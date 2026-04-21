// Translation of pcgen.gui2.util.JTableEx

import 'package:flutter/material.dart';

import 'table/sortable_table_model.dart';
import 'table/sortable_table_row_sorter.dart';

/// Callback fired when the user double-taps a cell.
typedef TableDoubleClickCallback = void Function(int row, int column, dynamic value);

/// Flutter equivalent of JTableEx. Renders a [SortableTableModel] as a
/// scrollable [DataTable] and supports double-tap events and auto-sorting.
class JTableEx extends StatefulWidget {
  static const int actionDoubleclick = 2042;

  final SortableTableModel? model;
  final bool autoCreateRowSorter;
  final TableDoubleClickCallback? onDoubleTap;

  const JTableEx({
    super.key,
    this.model,
    this.autoCreateRowSorter = false,
    this.onDoubleTap,
  });

  @override
  State<JTableEx> createState() => JTableExState();
}

class JTableExState extends State<JTableEx> {
  SortableTableRowSorter? _sorter;

  @override
  void initState() {
    super.initState();
    if (widget.autoCreateRowSorter && widget.model != null) {
      _sorter = SortableTableRowSorter(widget.model!);
    }
  }

  @override
  void didUpdateWidget(JTableEx oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      if (widget.autoCreateRowSorter && widget.model != null) {
        _sorter = SortableTableRowSorter(widget.model!);
      } else {
        _sorter = null;
      }
    }
  }

  void sortModel() {
    _sorter?.sort();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    if (model == null) return const SizedBox.shrink();

    final int rowCount = model.getRowCount();
    final int colCount = model.getColumnCount();

    final columns = List.generate(
      colCount,
      (c) => DataColumn(
        label: Text(model.getColumnName(c) ?? ''),
        onSort: widget.autoCreateRowSorter
            ? (col, ascending) {
                _sorter?.toggleSortOrder(col);
                setState(() {});
              }
            : null,
      ),
    );

    final rows = List.generate(rowCount, (r) {
      return DataRow(
        cells: List.generate(colCount, (c) {
          final value = model.getValueAt(r, c);
          return DataCell(
            Text(value?.toString() ?? ''),
            onDoubleTap: widget.onDoubleTap == null
                ? null
                : () => widget.onDoubleTap!(r, c, value),
          );
        }),
      );
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(columns: columns, rows: rows),
      ),
    );
  }
}
