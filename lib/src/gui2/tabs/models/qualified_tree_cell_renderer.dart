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
// Translation of pcgen.gui2.tabs.models.QualifiedTreeCellRenderer

import 'package:flutter/material.dart';

/// Tree cell renderer that shows qualification status via text color:
/// - qualified items: default color
/// - unqualified items: grey
/// - automatic items: blue
class QualifiedTreeCellRenderer extends StatelessWidget {
  final dynamic item;
  final bool isSelected;
  final bool isExpanded;
  final bool hasChildren;

  const QualifiedTreeCellRenderer({
    super.key,
    required this.item,
    this.isSelected = false,
    this.isExpanded = false,
    this.hasChildren = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = _getLabel();
    final style = _getStyle(context);

    return Container(
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Row(
        children: [
          if (hasChildren)
            Icon(isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                size: 16)
          else
            const SizedBox(width: 16),
          Text(label, style: style),
        ],
      ),
    );
  }

  String _getLabel() {
    if (item is Map) return item['name'] as String? ?? '';
    return item?.toString() ?? '';
  }

  TextStyle _getStyle(BuildContext context) {
    if (item is Map) {
      final automatic = item['automatic'] as bool? ?? false;
      if (automatic) return const TextStyle(color: Colors.blue, fontSize: 13);
      final qualified = item['qualified'] as bool? ?? true;
      if (!qualified) return const TextStyle(color: Colors.grey, fontSize: 13);
    }
    return const TextStyle(fontSize: 13);
  }
}
