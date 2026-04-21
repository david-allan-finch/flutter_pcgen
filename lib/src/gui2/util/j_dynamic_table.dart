//
// Copyright 2011 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.util.JDynamicTable

import 'package:flutter/material.dart';

import 'package:flutter_pcgen/src/gui2/util/table/dynamic_table_column_model.dart';
import 'package:flutter_pcgen/src/gui2/util/j_table_ex.dart';
import 'package:flutter_pcgen/src/gui2/util/j_table_menu_button.dart';

/// A table with dynamically show/hide-able columns, managed via a corner
/// drop-down button. Wraps [JTableEx] and adds column-visibility controls
/// backed by a [DynamicTableColumnModel].
class JDynamicTable extends StatefulWidget {
  final DynamicTableColumnModel? columnModel;
  final TableDoubleClickCallback? onDoubleTap;

  const JDynamicTable({
    super.key,
    this.columnModel,
    this.onDoubleTap,
  });

  @override
  State<JDynamicTable> createState() => _JDynamicTableState();
}

class _JDynamicTableState extends State<JDynamicTable> {
  DynamicTableColumnModel? _columnModel;

  @override
  void initState() {
    super.initState();
    _columnModel = widget.columnModel;
  }

  @override
  void didUpdateWidget(JDynamicTable old) {
    super.didUpdateWidget(old);
    if (widget.columnModel != old.columnModel) {
      setState(() => _columnModel = widget.columnModel);
    }
  }

  List<PopupMenuEntry<dynamic>> _buildMenuItems(BuildContext context) {
    final model = _columnModel;
    if (model == null) return [];
    return model.getAvailableColumns().map((col) {
      final visible = model.isVisible(col);
      return CheckedPopupMenuItem<dynamic>(
        value: col,
        checked: visible,
        child: Text(col.headerValue?.toString() ?? ''),
        onTap: () {
          setState(() => model.setVisible(col, !visible));
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final model = _columnModel;
    final hasAvailable =
        model != null && model.getAvailableColumns().isNotEmpty;

    return Stack(
      children: [
        JTableEx(
          model: null, // model connection handled externally
          onDoubleTap: widget.onDoubleTap,
        ),
        if (hasAvailable)
          Positioned(
            top: 0,
            right: 0,
            child: JTableMenuButton(itemBuilder: _buildMenuItems),
          ),
      ],
    );
  }
}
