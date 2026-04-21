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
// Translation of pcgen.gui2.filter.FilteredTreeViewTable

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/filter/filtered_tree_view_model.dart';
import 'package:flutter_pcgen/src/gui2/filter/filter.dart';
import 'package:flutter_pcgen/src/gui2/filter/filter_bar.dart';

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
